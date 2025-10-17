<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'shop_id',
        'category_id',
        'barcode',
        'name',
        'description',
        'price',
        'cost_price',
        'stock_quantity',
        'min_stock',
        'image',
        'is_active',
    ];

    /**
     * The attributes that should be cast.
     */
    protected $casts = [
        'price' => 'decimal:2',
        'cost_price' => 'decimal:2',
        'stock_quantity' => 'integer',
        'min_stock' => 'integer',
        'is_active' => 'boolean',
    ];

    /**
     * Product belongs to a Shop.
     */
    public function shop()
    {
        return $this->belongsTo(Shop::class);
    }

    /**
     * Product belongs to a Category (nullable).
     */
    public function category()
    {
        return $this->belongsTo(Category::class);
    }
}
