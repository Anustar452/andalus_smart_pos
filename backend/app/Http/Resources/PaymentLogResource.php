<?php
// app/Http/Resources/PaymentLogResource.php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PaymentLogResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'payment_gateway' => $this->payment_gateway,
            'reference_number' => $this->reference_number,
            'amount' => $this->amount,
            'status' => $this->status,
            'error_message' => $this->error_message,
            'request_data' => $this->request_data,
            'response_data' => $this->response_data,
            'created_at' => $this->created_at->format('Y-m-d H:i:s'),
            'updated_at' => $this->updated_at,
        ];
    }
}