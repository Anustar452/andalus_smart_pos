<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class TransactionItemResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array<string, mixed>
     */
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'transaction_id' => $this->transaction_id,
            'product_id' => $this->product_id,
            'quantity' => $this->quantity,
            'unit_price' => $this->unit_price,
            'total_price' => $this->total_price,
            'tax_rate' => $this->tax_rate,
            'discount_amount' => $this->discount_amount,

            // Related models (optional but useful for API consumers)
            'product' => $this->whenLoaded('product', function () {
                return [
                    'id' => $this->product->id,
                    'name' => $this->product->name,
                    'price' => $this->product->price,
                    'is_active' => $this->product->is_active,
                ];
            }),

            'transaction' => $this->whenLoaded('transaction', function () {
                return [
                    'id' => $this->transaction->id,
                    'type' => $this->transaction->type ?? null,
                    'total_amount' => $this->transaction->total_amount ?? null,
                    'status' => $this->transaction->status ?? null,
                ];
            }),

            // Helpful computed values
            'subtotal' => round($this->quantity * $this->unit_price, 2),
            'final_total' => round(($this->total_price ?? 0) - ($this->discount_amount ?? 0), 2),

            // Metadata
            'created_at' => $this->created_at?->toDateTimeString(),
            'updated_at' => $this->updated_at?->toDateTimeString(),
        ];
    }
}
