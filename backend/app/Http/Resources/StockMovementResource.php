<?php
// app/Http/Resources/StockMovementResource.php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class StockMovementResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'type' => $this->type,
            'quantity' => $this->quantity,
            'previous_stock' => $this->previous_stock,
            'new_stock' => $this->new_stock,
            'reason' => $this->reason,
            'user_name' => $this->user->name,
            'product_name' => $this->product->name,
            'reference_type' => $this->reference_type,
            'reference_id' => $this->reference_id,
            'created_at' => $this->created_at->format('Y-m-d H:i:s'),
            'updated_at' => $this->updated_at,
        ];
    }
}