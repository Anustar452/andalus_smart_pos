<?php
// app/Http/Resources/CategoryResource.php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CategoryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'color' => $this->color,
            'is_active' => $this->is_active,
            'products_count' => $this->whenLoaded('products', function () {
                return $this->products->count();
            }),
            'active_products_count' => $this->whenLoaded('products', function () {
                return $this->products->where('is_active', true)->count();
            }),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}