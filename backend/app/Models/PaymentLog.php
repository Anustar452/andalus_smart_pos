<?php
// app/Models/PaymentLog.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PaymentLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'transaction_id',
        'payment_gateway',
        'reference_number',
        'amount',
        'status',
        'request_data',
        'response_data',
        'error_message',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'request_data' => 'array',
        'response_data' => 'array',
    ];

    public function transaction()
    {
        return $this->belongsTo(Transaction::class);
    }

    public function markAsSuccess($responseData = null)
    {
        $this->update([
            'status' => 'success',
            'response_data' => $responseData,
        ]);
    }

    public function markAsFailed($errorMessage, $responseData = null)
    {
        $this->update([
            'status' => 'failed',
            'error_message' => $errorMessage,
            'response_data' => $responseData,
        ]);
    }
}