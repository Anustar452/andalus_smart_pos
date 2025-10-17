<?php
// app/Models/Shop.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Shop extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'address',
        'phone',
        'tin_number',
        'logo',
        'settings',
        'is_active',
    ];

    protected $casts = [
        'settings' => 'array',
        'is_active' => 'boolean',
    ];

    public function users()
    {
        return $this->hasMany(User::class);
    }

    public function products()
    {
        return $this->hasMany(Product::class);
    }

    public function categories()
    {
        return $this->hasMany(Category::class);
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }

    public function getDefaultSettingsAttribute()
    {
        return array_merge([
            'tax_rate' => 0,
            'currency' => 'ETB',
            'receipt_header' => $this->name,
            'receipt_footer' => 'Thank you for your business!',
            'print_receipt' => true,
            'low_stock_threshold' => 5,
        ], $this->settings ?? []);
    }
}