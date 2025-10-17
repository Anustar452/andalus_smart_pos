<?php

namespace App\Http\Controllers;

use App\Models\TransactionItem;
use App\Http\Resources\TransactionItemResource;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class TransactionItemController extends Controller
{
    /**
     * Display a listing of the transaction items for a transaction.
     */
    public function index(Request $request)
    {
        $query = TransactionItem::query()
            ->with(['product', 'transaction'])
            ->orderByDesc('created_at');

        // Optional filtering by transaction_id
        if ($request->has('transaction_id')) {
            $query->where('transaction_id', $request->transaction_id);
        }

        $items = $query->get();

        return TransactionItemResource::collection($items);
    }

    /**
     * Store a newly created transaction item in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'transaction_id' => ['required', 'exists:transactions,id'],
            'product_id' => ['required', 'exists:products,id'],
            'quantity' => ['required', 'integer', 'min:1'],
            'unit_price' => ['required', 'numeric', 'min:0'],
            'tax_rate' => ['nullable', 'numeric', 'min:0'],
            'discount_amount' => ['nullable', 'numeric', 'min:0'],
        ]);

        $item = TransactionItem::create($validated);

        return new TransactionItemResource($item->load(['product', 'transaction']));
    }

    /**
     * Display the specified transaction item.
     */
    public function show(TransactionItem $transactionItem)
    {
        return new TransactionItemResource($transactionItem->load(['product', 'transaction']));
    }

    /**
     * Update the specified transaction item in storage.
     */
    public function update(Request $request, TransactionItem $transactionItem)
    {
        $validated = $request->validate([
            'product_id' => ['sometimes', 'exists:products,id'],
            'quantity' => ['sometimes', 'integer', 'min:1'],
            'unit_price' => ['sometimes', 'numeric', 'min:0'],
            'tax_rate' => ['nullable', 'numeric', 'min:0'],
            'discount_amount' => ['nullable', 'numeric', 'min:0'],
        ]);

        $transactionItem->update($validated);

        return new TransactionItemResource($transactionItem->refresh()->load(['product', 'transaction']));
    }

    /**
     * Remove the specified transaction item from storage.
     */
    public function destroy(TransactionItem $transactionItem)
    {
        $transactionItem->delete();

        return response()->json(['message' => 'Transaction item deleted successfully']);
    }
}
