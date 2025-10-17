<?php
// app/Services/PaymentService.php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
class PaymentService
{
   
    public function processTelebirrPayment($paymentData)
    {
        try {
            $baseUrl = config('services.telebirr.base_url');
            $apiKey = config('services.telebirr.api_key');
            $secretKey = config('services.telebirr.secret_key');

            $payload = [
                'amount' => $paymentData['amount'],
                'customer_phone' => $paymentData['customer_phone'],
                'transaction_id' => $paymentData['transaction_id'],
                'callback_url' => config('app.url') . '/api/payment/telebirr/callback',
                'timestamp' => now()->timestamp,
            ];

            // Generate signature
            $signature = hash_hmac('sha256', json_encode($payload), $secretKey);

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $apiKey,
                'Content-Type' => 'application/json',
                'Signature' => $signature,
            ])->post($baseUrl . '/payment/initiate', $payload);

            $responseData = $response->json();

            if ($response->successful() && $responseData['status'] === 'success') {
                return [
                    'success' => true,
                    'reference' => $responseData['data']['reference'],
                    'payment_url' => $responseData['data']['payment_url'],
                    'response_data' => $responseData,
                ];
            }

            return [
                'success' => false,
                'error' => $responseData['message'] ?? 'Payment initiation failed',
                'response_data' => $responseData,
            ];
            
        } catch (\Exception $e) {
            Log::error('Telebirr payment error: ' . $e->getMessage());
            return [
                'success' => false, 
                'error' => 'Payment service unavailable: ' . $e->getMessage()
            ];
        }
    }

    public function processCBEBirrPayment($paymentData)
    {
        try {
            // CBE Birr integration logic
            $baseUrl = config('services.cbe_birr.base_url');
            $merchantId = config('services.cbe_birr.merchant_id');
            $apiKey = config('services.cbe_birr.api_key');

            $payload = [
                'merchantId' => $merchantId,
                'amount' => $paymentData['amount'],
                'customerPhone' => $paymentData['customer_phone'],
                'transactionId' => $paymentData['transaction_id'],
                'callbackUrl' => config('app.url') . '/api/payment/cbe-birr/callback',
            ];

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $apiKey,
                'Content-Type' => 'application/json',
            ])->post($baseUrl . '/payment/request', $payload);

            $responseData = $response->json();

            if ($response->successful() && $responseData['responseCode'] === '200') {
                return [
                    'success' => true,
                    'reference' => $responseData['referenceNumber'],
                    'response_data' => $responseData,
                ];
            }

            return [
                'success' => false,
                'error' => $responseData['responseDescription'] ?? 'CBE Birr payment failed',
                'response_data' => $responseData,
            ];

        } catch (\Exception $e) {
            Log::error('CBE Birr payment error: ' . $e->getMessage());
            return [
                'success' => false, 
                'error' => 'CBE Birr service unavailable'
            ];
        }
    }

    public function processChapaPayment($paymentData)
    {
        try {
            $baseUrl = config('services.chapa.base_url');
            $secretKey = config('services.chapa.secret_key');

            $payload = [
                'amount' => $paymentData['amount'],
                'currency' => 'ETB',
                'email' => $paymentData['customer_email'],
                'first_name' => 'Customer',
                'last_name' => 'Customer',
                'tx_ref' => $paymentData['transaction_id'],
                'callback_url' => config('app.url') . '/api/payment/chapa/callback',
                'return_url' => config('app.url') . '/payment/success',
            ];

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $secretKey,
                'Content-Type' => 'application/json',
            ])->post($baseUrl . '/transaction/initialize', $payload);

            $responseData = $response->json();

            if ($response->successful() && $responseData['status'] === 'success') {
                return [
                    'success' => true,
                    'reference' => $responseData['data']['reference'],
                    'checkout_url' => $responseData['data']['checkout_url'],
                    'response_data' => $responseData,
                ];
            }

            return [
                'success' => false,
                'error' => $responseData['message'] ?? 'Chapa payment failed',
                'response_data' => $responseData,
            ];

        } catch (\Exception $e) {
            Log::error('Chapa payment error: ' . $e->getMessage());
            return [
                'success' => false, 
                'error' => 'Chapa service unavailable'
            ];
        }
    }

    public function verifyTelebirrPayment($reference)
    {
        try {
            $baseUrl = config('services.telebirr.base_url');
            $apiKey = config('services.telebirr.api_key');

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $apiKey,
            ])->get($baseUrl . '/payment/verify/' . $reference);

            $responseData = $response->json();

            if ($response->successful() && $responseData['status'] === 'success') {
                return [
                    'success' => true,
                    'verified' => true,
                    'payment_data' => $responseData['data'],
                ];
            }

            return ['success' => false, 'verified' => false];

        } catch (\Exception $e) {
            Log::error('Telebirr verification error: ' . $e->getMessage());
            return ['success' => false, 'verified' => false];
        }
    }
}