<?php
// app/Http/Resources/TransactionResource.php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TransactionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'transaction_number' => $this->transaction_number,
            'total_amount' => $this->total_amount,
            'tax_amount' => $this->tax_amount,
            'discount_amount' => $this->discount_amount,
            'paid_amount' => $this->paid_amount,
            'change_amount' => $this->change_amount,
            'payment_method' => $this->payment_method,
            'payment_reference' => $this->payment_reference,
            'status' => $this->status,
            'is_online' => $this->is_online,
            'customer_phone' => $this->customer_phone,
            'customer_email' => $this->customer_email,
            'items_count' => $this->items_count,
            'user' => $this->whenLoaded('user', function () {
                return [
                    'id' => $this->user->id,
                    'name' => $this->user->name,
                    'email' => $this->user->email,
                ];
            }),
            'items' => $this->whenLoaded('items', function () {
                return TransactionItemResource::collection($this->items);
            }),
            'created_at' => $this->created_at->format('Y-m-d H:i:s'),
            'updated_at' => $this->updated_at,
        ];
    }
}
