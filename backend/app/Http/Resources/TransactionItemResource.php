<?php
// app/Http/Resources/TransactionItemResource.php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TransactionItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'product_id' => $this->product_id,
            'product_name' => $this->product->name,
            'product_barcode' => $this->product->barcode,
            'quantity' => $this->quantity,
            'unit_price' => $this->unit_price,
            'total_price' => $this->total_price,
            'tax_rate' => $this->tax_rate,
            'discount_amount' => $this->discount_amount,
            'created_at' => $this->created_at,
        ];
    }
}