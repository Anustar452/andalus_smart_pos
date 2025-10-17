<?php
// app/Models/Transaction.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'shop_id',
        'user_id',
        'transaction_number',
        'total_amount',
        'tax_amount',
        'discount_amount',
        'paid_amount',
        'change_amount',
        'payment_method',
        'payment_reference',
        'status',
        'is_online',
        'customer_phone',
        'customer_email',
        'synced_at',
    ];

    protected $casts = [
        'total_amount' => 'decimal:2',
        'tax_amount' => 'decimal:2',
        'discount_amount' => 'decimal:2',
        'paid_amount' => 'decimal:2',
        'change_amount' => 'decimal:2',
        'is_online' => 'boolean',
        'synced_at' => 'datetime',
    ];

    public function shop()
    {
        return $this->belongsTo(Shop::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function items()
    {
        return $this->hasMany(TransactionItem::class);
    }

    public function paymentLogs()
    {
        return $this->hasMany(PaymentLog::class);
    }

    public static function generateTransactionNumber($shopId)
    {
        $date = now()->format('Ymd');
        $lastTransaction = self::where('shop_id', $shopId)
            ->where('transaction_number', 'like', "TXN{$shopId}{$date}%")
            ->orderBy('id', 'desc')
            ->first();

        $sequence = $lastTransaction ? 
            (int)substr($lastTransaction->transaction_number, -4) + 1 : 1;

        return "TXN{$shopId}{$date}" . str_pad($sequence, 4, '0', STR_PAD_LEFT);
    }

    public function getItemsCountAttribute()
    {
        return $this->items->sum('quantity');
    }

    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    public function scopeToday($query)
    {
        return $query->whereDate('created_at', today());
    }

    public function scopeThisWeek($query)
    {
        return $query->whereBetween('created_at', [now()->startOfWeek(), now()->endOfWeek()]);
    }

    public function scopeThisMonth($query)
    {
        return $query->whereMonth('created_at', now()->month)
                    ->whereYear('created_at', now()->year);
    }
}