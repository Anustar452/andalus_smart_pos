<?php
// app/Http/Requests/StoreTransactionRequest.php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreTransactionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.unit_price' => 'required|numeric|min:0',
            'payment_method' => 'required|in:cash,telebirr,cbe_birr,chapa,card',
            'paid_amount' => 'required|numeric|min:0',
            'customer_phone' => 'nullable|string|max:20',
            'customer_email' => 'nullable|email',
            'notes' => 'nullable|string|max:500',
        ];
    }

    public function messages(): array
    {
        return [
            'items.required' => 'At least one item is required for the transaction.',
            'items.*.product_id.exists' => 'One or more products are invalid.',
            'items.*.quantity.min' => 'Quantity must be at least 1.',
            'paid_amount.min' => 'Paid amount must be positive.',
        ];
    }
}