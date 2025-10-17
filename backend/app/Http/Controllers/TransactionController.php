<?php
// app/Http/Controllers/TransactionController.php

namespace App\Http\Controllers;

use App\Models\Transaction;
use App\Models\Product;
use App\Models\StockMovement;
use App\Models\PaymentLog;
use App\Http\Resources\TransactionResource;
use App\Services\PaymentService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Validation\ValidationException;

class TransactionController extends Controller
{
    use AuthorizesRequests;

    protected $paymentService;

    public function __construct(PaymentService $paymentService)
    {
        $this->paymentService = $paymentService;
    }

    public function index(Request $request)
    {
        $query = Transaction::with(['items.product', 'user'])
            ->where('shop_id', $request->user()->shop_id)
            ->orderBy('created_at', 'desc');

        // Date filters
        if ($request->has('date_from')) {
            $query->whereDate('created_at', '>=', $request->date_from);
        }

        if ($request->has('date_to')) {
            $query->whereDate('created_at', '<=', $request->date_to);
        }

        // Status filter
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Payment method filter
        if ($request->has('payment_method')) {
            $query->where('payment_method', $request->payment_method);
        }

        $transactions = $query->paginate(50);

        return TransactionResource::collection($transactions);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.unit_price' => 'required|numeric|min:0',
            'payment_method' => 'required|in:cash,telebirr,cbe_birr,chapa,card',
            'paid_amount' => 'required|numeric|min:0',
            'customer_phone' => 'nullable|string|max:20',
            'customer_email' => 'nullable|email',
            'notes' => 'nullable|string',
        ]);

        return DB::transaction(function () use ($validated, $request) {
            $user = $request->user();
            $shop = $user->shop;

            // Calculate totals and validate stock
            $totalAmount = 0;
            $itemsData = [];

            foreach ($validated['items'] as $item) {
                $product = Product::find($item['product_id']);

                // Check if product belongs to user's shop
                if ($product->shop_id !== $user->shop_id) {
                    throw ValidationException::withMessages([
                        'items' => ['Invalid product selected.']
                    ]);
                }

                // Check stock availability
                if ($product->stock_quantity < $item['quantity']) {
                    throw ValidationException::withMessages([
                        'items' => ["Insufficient stock for {$product->name}. Available: {$product->stock_quantity}"]
                    ]);
                }

                $itemTotal = $item['quantity'] * $item['unit_price'];
                $totalAmount += $itemTotal;

                $itemsData[] = [
                    'product' => $product,
                    'quantity' => $item['quantity'],
                    'unit_price' => $item['unit_price'],
                    'total_price' => $itemTotal,
                ];
            }

            // Validate paid amount
            if ($validated['paid_amount'] < $totalAmount && $validated['payment_method'] === 'cash') {
                throw ValidationException::withMessages([
                    'paid_amount' => ['Paid amount must be greater than or equal to total amount for cash payments.']
                ]);
            }

            $changeAmount = max(0, $validated['paid_amount'] - $totalAmount);

            // Create transaction
            $transaction = Transaction::create([
                'shop_id' => $user->shop_id,
                'user_id' => $user->id,
                'transaction_number' => Transaction::generateTransactionNumber($user->shop_id),
                'total_amount' => $totalAmount,
                'tax_amount' => 0, // Could be calculated based on shop settings
                'discount_amount' => 0, // Could be added to validation
                'paid_amount' => $validated['paid_amount'],
                'change_amount' => $changeAmount,
                'payment_method' => $validated['payment_method'],
                'customer_phone' => $validated['customer_phone'],
                'customer_email' => $validated['customer_email'],
                'status' => 'completed',
            ]);

            // Create transaction items and update stock
            foreach ($itemsData as $itemData) {
                $transaction->items()->create([
                    'product_id' => $itemData['product']->id,
                    'quantity' => $itemData['quantity'],
                    'unit_price' => $itemData['unit_price'],
                    'total_price' => $itemData['total_price'],
                ]);

                // Update stock and record movement
                StockMovement::recordMovement(
                    $itemData['product'],
                    'out',
                    $itemData['quantity'],
                    $user,
                    'POS Sale',
                    $transaction
                );
            }

            // Process electronic payment if needed
            $paymentLog = null;
            if (in_array($validated['payment_method'], ['telebirr', 'cbe_birr', 'chapa'])) {
                $paymentResult = $this->processElectronicPayment(
                    $transaction, 
                    $validated['payment_method'],
                    $validated['customer_phone'] ?? null,
                    $validated['customer_email'] ?? null
                );

                $paymentLog = PaymentLog::create([
                    'transaction_id' => $transaction->id,
                    'payment_gateway' => $validated['payment_method'],
                    'reference_number' => $paymentResult['reference'] ?? $transaction->transaction_number,
                    'amount' => $totalAmount,
                    'status' => $paymentResult['success'] ? 'success' : 'failed',
                    'request_data' => $paymentResult['request_data'] ?? null,
                    'response_data' => $paymentResult['response_data'] ?? null,
                    'error_message' => $paymentResult['error'] ?? null,
                ]);

                if (!$paymentResult['success']) {
                    $transaction->update(['status' => 'failed']);
                    throw new \Exception('Payment failed: ' . $paymentResult['error']);
                }

                $transaction->update([
                    'payment_reference' => $paymentResult['reference'] ?? null,
                    'is_online' => true,
                ]);
            }

            return new TransactionResource($transaction->load(['items.product', 'user']));
        });
    }

    public function show(Transaction $transaction)
    {
        $this->authorize('view', $transaction);
        return new TransactionResource($transaction->load(['items.product', 'user', 'paymentLogs']));
    }

    public function refund(Request $request, Transaction $transaction)
    {
        $this->authorize('refund', $transaction);

        if ($transaction->status !== 'completed') {
            return response()->json([
                'message' => 'Only completed transactions can be refunded.'
            ], 422);
        }

        return DB::transaction(function () use ($transaction, $request) {
            // Create refund transaction
            $refundTransaction = $transaction->replicate();
            $refundTransaction->transaction_number = Transaction::generateTransactionNumber($transaction->shop_id);
            $refundTransaction->total_amount = -$transaction->total_amount;
            $refundTransaction->paid_amount = -$transaction->paid_amount;
            $refundTransaction->change_amount = 0;
            $refundTransaction->status = 'refunded';
            $refundTransaction->save();

            // Create refund items and return stock
            foreach ($transaction->items as $item) {
                $refundTransaction->items()->create([
                    'product_id' => $item->product_id,
                    'quantity' => $item->quantity,
                    'unit_price' => $item->unit_price,
                    'total_price' => -$item->total_price,
                ]);

                // Return items to stock
                StockMovement::recordMovement(
                    $item->product,
                    'return',
                    $item->quantity,
                    $request->user(),
                    'Sale Refund',
                    $refundTransaction
                );
            }

            $transaction->update(['status' => 'refunded']);

            return new TransactionResource($refundTransaction->load(['items.product', 'user']));
        });
    }

    private function processElectronicPayment($transaction, $method, $phone, $email)
    {
        $paymentData = [
            'amount' => $transaction->total_amount,
            'transaction_id' => $transaction->transaction_number,
            'customer_phone' => $phone,
            'customer_email' => $email,
        ];

        switch ($method) {
            case 'telebirr':
                return $this->paymentService->processTelebirrPayment($paymentData);
            case 'cbe_birr':
                return $this->paymentService->processCBEBirrPayment($paymentData);
            case 'chapa':
                return $this->paymentService->processChapaPayment($paymentData);
            default:
                return ['success' => false, 'error' => 'Unknown payment method'];
        }
    }

    public function dailySummary(Request $request)
    {
        $date = $request->get('date', now()->format('Y-m-d'));

        $summary = Transaction::where('shop_id', $request->user()->shop_id)
            ->whereDate('created_at', $date)
            ->selectRaw('
                COUNT(*) as total_transactions,
                SUM(total_amount) as total_sales,
                AVG(total_amount) as average_sale,
                SUM(paid_amount) as total_cash_in,
                SUM(change_amount) as total_change,
                MIN(total_amount) as min_sale,
                MAX(total_amount) as max_sale
            ')
            ->first();

        $paymentMethods = Transaction::where('shop_id', $request->user()->shop_id)
            ->whereDate('created_at', $date)
            ->selectRaw('payment_method, COUNT(*) as count, SUM(total_amount) as total')
            ->groupBy('payment_method')
            ->get();

        return response()->json([
            'date' => $date,
            'summary' => $summary,
            'payment_methods' => $paymentMethods,
        ]);
    }
}