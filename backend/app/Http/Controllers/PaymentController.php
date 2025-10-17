<?php
// app/Http/Controllers/PaymentController.php

namespace App\Http\Controllers;

use App\Models\Transaction;
use App\Models\PaymentLog;
use App\Services\PaymentService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;

class PaymentController extends Controller
{
    use AuthorizesRequests;

    protected $paymentService;

    public function __construct(PaymentService $paymentService)
    {
        $this->paymentService = $paymentService;
    }

    public function telebirrCallback(Request $request)
    {
        Log::info('Telebirr Callback Received:', $request->all());

        try {
            $validated = $request->validate([
                'reference' => 'required|string',
                'status' => 'required|string',
                'transaction_id' => 'required|string',
                'amount' => 'required|numeric',
            ]);

            $transaction = Transaction::where('transaction_number', $validated['transaction_id'])->first();

            if (!$transaction) {
                Log::error('Transaction not found for Telebirr callback', $validated);
                return response()->json(['message' => 'Transaction not found'], 404);
            }

            DB::transaction(function () use ($transaction, $validated) {
                $paymentLog = PaymentLog::where('reference_number', $validated['reference'])
                    ->where('transaction_id', $transaction->id)
                    ->first();

                if ($paymentLog) {
                    if ($validated['status'] === 'success') {
                        $paymentLog->markAsSuccess($validated);
                        $transaction->update([
                            'status' => 'completed',
                            'payment_reference' => $validated['reference'],
                        ]);
                    } else {
                        $paymentLog->markAsFailed('Payment failed via callback', $validated);
                        $transaction->update(['status' => 'failed']);
                    }
                }
            });

            return response()->json(['message' => 'Callback processed successfully']);

        } catch (\Exception $e) {
            Log::error('Telebirr callback processing error: ' . $e->getMessage());
            return response()->json(['message' => 'Error processing callback'], 500);
        }
    }

    public function cbeBirrCallback(Request $request)
    {
        Log::info('CBE Birr Callback Received:', $request->all());

        try {
            $validated = $request->validate([
                'referenceNumber' => 'required|string',
                'responseCode' => 'required|string',
                'transactionId' => 'required|string',
                'amount' => 'required|numeric',
            ]);

            $transaction = Transaction::where('transaction_number', $validated['transactionId'])->first();

            if (!$transaction) {
                Log::error('Transaction not found for CBE Birr callback', $validated);
                return response()->json(['message' => 'Transaction not found'], 404);
            }

            DB::transaction(function () use ($transaction, $validated) {
                $paymentLog = PaymentLog::where('reference_number', $validated['referenceNumber'])
                    ->where('transaction_id', $transaction->id)
                    ->first();

                if ($paymentLog) {
                    if ($validated['responseCode'] === '200') {
                        $paymentLog->markAsSuccess($validated);
                        $transaction->update([
                            'status' => 'completed',
                            'payment_reference' => $validated['referenceNumber'],
                        ]);
                    } else {
                        $paymentLog->markAsFailed('Payment failed: ' . ($validated['responseDescription'] ?? 'Unknown error'), $validated);
                        $transaction->update(['status' => 'failed']);
                    }
                }
            });

            return response()->json(['message' => 'Callback processed successfully']);

        } catch (\Exception $e) {
            Log::error('CBE Birr callback processing error: ' . $e->getMessage());
            return response()->json(['message' => 'Error processing callback'], 500);
        }
    }

    public function chapaCallback(Request $request)
    {
        Log::info('Chapa Callback Received:', $request->all());

        try {
            $validated = $request->validate([
                'tx_ref' => 'required|string',
                'status' => 'required|string',
                'transaction_id' => 'nullable|string',
            ]);

            $transaction = Transaction::where('transaction_number', $validated['tx_ref'])->first();

            if (!$transaction) {
                Log::error('Transaction not found for Chapa callback', $validated);
                return response()->json(['message' => 'Transaction not found'], 404);
            }

            DB::transaction(function () use ($transaction, $validated) {
                $paymentLog = PaymentLog::where('reference_number', $validated['tx_ref'])
                    ->where('transaction_id', $transaction->id)
                    ->first();

                if ($paymentLog) {
                    if ($validated['status'] === 'success') {
                        $paymentLog->markAsSuccess($validated);
                        $transaction->update([
                            'status' => 'completed',
                            'payment_reference' => $validated['transaction_id'] ?? $validated['tx_ref'],
                        ]);
                    } else {
                        $paymentLog->markAsFailed('Payment failed via callback', $validated);
                        $transaction->update(['status' => 'failed']);
                    }
                }
            });

            return response()->json(['message' => 'Callback processed successfully']);

        } catch (\Exception $e) {
            Log::error('Chapa callback processing error: ' . $e->getMessage());
            return response()->json(['message' => 'Error processing callback'], 500);
        }
    }

    public function verifyPayment(Request $request, Transaction $transaction)
    {
        $this->authorize('view', $transaction);

        if (!in_array($transaction->payment_method, ['telebirr', 'cbe_birr', 'chapa'])) {
            return response()->json([
                'message' => 'Payment verification only available for electronic payments'
            ], 422);
        }

        try {
            $paymentLog = $transaction->paymentLogs()->latest()->first();

            if (!$paymentLog) {
                return response()->json([
                    'message' => 'No payment log found for this transaction'
                ], 404);
            }

            $verificationResult = $this->paymentService->verifyTelebirrPayment($paymentLog->reference_number);

            return response()->json([
                'transaction_status' => $transaction->status,
                'payment_log_status' => $paymentLog->status,
                'verification_result' => $verificationResult,
            ]);

        } catch (\Exception $e) {
            Log::error('Payment verification error: ' . $e->getMessage());
            return response()->json([
                'message' => 'Error verifying payment'
            ], 500);
        }
    }
}