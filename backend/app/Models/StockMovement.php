<?php
// app/Models/StockMovement.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class StockMovement extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_id',
        'user_id',
        'type',
        'quantity',
        'previous_stock',
        'new_stock',
        'reference_type',
        'reference_id',
        'reason',
    ];

    protected $casts = [
        'previous_stock' => 'integer',
        'new_stock' => 'integer',
    ];

    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function reference()
    {
        return $this->morphTo();
    }

    public static function recordMovement($product, $type, $quantity, $user, $reason = null, $reference = null)
    {
        $previousStock = $product->stock_quantity;
        
        if ($type === 'in' || $type === 'return') {
            $product->increment('stock_quantity', $quantity);
        } elseif ($type === 'out') {
            $product->decrement('stock_quantity', $quantity);
        } elseif ($type === 'adjustment') {
            $product->update(['stock_quantity' => $quantity]);
        }

        $product->refresh();

        return self::create([
            'product_id' => $product->id,
            'user_id' => $user->id,
            'type' => $type,
            'quantity' => $quantity,
            'previous_stock' => $previousStock,
            'new_stock' => $product->stock_quantity,
            'reference_type' => $reference ? get_class($reference) : null,
            'reference_id' => $reference ? $reference->id : null,
            'reason' => $reason,
        ]);
    }
}