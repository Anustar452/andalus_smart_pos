<?php
// app/Services/PaymentService.php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class PaymentService
{
    private $telebirrConfig;
    private $cbeBirrConfig;
    private $chapaConfig;

    public function __construct()
    {
        $this->telebirrConfig = [
            'base_url' => config('services.telebirr.base_url'),
            'api_key' => config('services.telebirr.api_key'),
            'secret_key' => config('services.telebirr.secret_key'),
            'merchant_id' => config('services.telebirr.merchant_id'),
        ];

        $this->cbeBirrConfig = [
            'base_url' => config('services.cbe_birr.base_url'),
            'merchant_id' => config('services.cbe_birr.merchant_id'),
            'api_key' => config('services.cbe_birr.api_key'),
            'terminal_id' => config('services.cbe_birr.terminal_id'),
        ];

        $this->chapaConfig = [
            'base_url' => config('services.chapa.base_url'),
            'secret_key' => config('services.chapa.secret_key'),
            'public_key' => config('services.chapa.public_key'),
        ];
    }

    public function processTelebirrPayment($paymentData)
    {
        try {
            $payload = [
                'outTradeNo' => $paymentData['transaction_id'],
                'subject' => 'POS Payment - ' . $paymentData['transaction_id'],
                'totalAmount' => $paymentData['amount'],
                'shortCode' => $this->telebirrConfig['merchant_id'],
                'notifyUrl' => config('app.url') . '/api/payment/telebirr/callback',
                'returnUrl' => config('app.url') . '/payment/success',
                'receiveName' => 'Andalus POS',
                'appId' => $this->telebirrConfig['api_key'],
                'timeoutExpress' => '30m',
                'nonce' => Str::random(32),
                'timestamp' => time() * 1000,
            ];

            // Generate signature
            $signatureString = $this->generateTelebirrSignature($payload);
            $payload['sign'] = $signatureString;

            Log::info('Telebirr Payment Request:', $payload);

            $response = Http::timeout(30)
                ->withHeaders([
                    'Content-Type' => 'application/json',
                    'Authorization' => 'Bearer ' . $this->telebirrConfig['api_key'],
                ])
                ->post($this->telebirrConfig['base_url'] . '/payment/create', $payload);

            $responseData = $response->json();
            Log::info('Telebirr Payment Response:', $responseData);

            if ($response->successful() && isset($responseData['code']) && $responseData['code'] == '200') {
                return [
                    'success' => true,
                    'reference' => $responseData['data']['tradeNo'] ?? $paymentData['transaction_id'],
                    'payment_url' => $responseData['data']['paymentUrl'] ?? null,
                    'qr_code' => $responseData['data']['qrCode'] ?? null,
                    'response_data' => $responseData,
                ];
            }

            $errorMessage = $responseData['message'] ?? $responseData['msg'] ?? 'Payment initiation failed';
            return [
                'success' => false,
                'error' => $errorMessage,
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

    private function generateTelebirrSignature($payload)
    {
        // Sort parameters alphabetically
        ksort($payload);
        
        $signString = '';
        foreach ($payload as $key => $value) {
            if ($key !== 'sign' && $value !== '' && !is_array($value)) {
                $signString .= $key . '=' . $value . '&';
            }
        }
        
        $signString = rtrim($signString, '&');
        $signString .= $this->telebirrConfig['secret_key'];
        
        return strtoupper(md5($signString));
    }

    public function processCBEBirrPayment($paymentData)
    {
        try {
            $payload = [
                'merchantId' => $this->cbeBirrConfig['merchant_id'],
                'terminalId' => $this->cbeBirrConfig['terminal_id'],
                'amount' => number_format($paymentData['amount'], 2, '.', ''),
                'currency' => 'ETB',
                'invoiceNo' => $paymentData['transaction_id'],
                'transactionDateTime' => now()->format('YmdHis'),
                'customerPhone' => $paymentData['customer_phone'],
                'additionalData' => 'POS Payment',
                'callbackUrl' => config('app.url') . '/api/payment/cbe-birr/callback',
            ];

            // Generate CBE Birr specific fields
            $payload['checkSum'] = $this->generateCbeBirrChecksum($payload);

            Log::info('CBE Birr Payment Request:', $payload);

            $response = Http::timeout(30)
                ->withHeaders([
                    'Content-Type' => 'application/json',
                    'Authorization' => 'Bearer ' . $this->cbeBirrConfig['api_key'],
                ])
                ->post($this->cbeBirrConfig['base_url'] . '/payment/initiate', $payload);

            $responseData = $response->json();
            Log::info('CBE Birr Payment Response:', $responseData);

            if ($response->successful() && isset($responseData['responseCode']) && $responseData['responseCode'] == '000') {
                return [
                    'success' => true,
                    'reference' => $responseData['referenceNumber'] ?? $paymentData['transaction_id'],
                    'payment_url' => $responseData['paymentUrl'] ?? null,
                    'response_data' => $responseData,
                ];
            }

            $errorMessage = $responseData['responseDescription'] ?? 'CBE Birr payment failed';
            return [
                'success' => false,
                'error' => $errorMessage,
                'response_data' => $responseData,
            ];

        } catch (\Exception $e) {
            Log::error('CBE Birr payment error: ' . $e->getMessage());
            return [
                'success' => false,
                'error' => 'CBE Birr service unavailable: ' . $e->getMessage()
            ];
        }
    }

    private function generateCbeBirrChecksum($payload)
    {
        $data = $payload['merchantId'] . $payload['terminalId'] . $payload['amount'] . 
                $payload['currency'] . $payload['invoiceNo'] . $payload['transactionDateTime'];
        
        return hash_hmac('sha256', $data, $this->cbeBirrConfig['api_key']);
    }

    public function processChapaPayment($paymentData)
    {
        try {
            $payload = [
                'amount' => $paymentData['amount'],
                'currency' => 'ETB',
                'email' => $paymentData['customer_email'] ?? 'customer@andaluspos.com',
                'first_name' => 'Customer',
                'last_name' => 'Customer',
                'tx_ref' => $paymentData['transaction_id'],
                'callback_url' => config('app.url') . '/api/payment/chapa/callback',
                'return_url' => config('app.url') . '/payment/success',
                'customization' => [
                    'title' => 'Andalus POS Payment',
                    'description' => 'Payment for transaction: ' . $paymentData['transaction_id'],
                ]
            ];

            Log::info('Chapa Payment Request:', $payload);

            $response = Http::timeout(30)
                ->withHeaders([
                    'Authorization' => 'Bearer ' . $this->chapaConfig['secret_key'],
                    'Content-Type' => 'application/json',
                ])
                ->post($this->chapaConfig['base_url'] . '/transaction/initialize', $payload);

            $responseData = $response->json();
            Log::info('Chapa Payment Response:', $responseData);

            if ($response->successful() && $responseData['status'] === 'success') {
                return [
                    'success' => true,
                    'reference' => $responseData['data']['reference'] ?? $paymentData['transaction_id'],
                    'checkout_url' => $responseData['data']['checkout_url'],
                    'response_data' => $responseData,
                ];
            }

            $errorMessage = $responseData['message'] ?? 'Chapa payment failed';
            return [
                'success' => false,
                'error' => $errorMessage,
                'response_data' => $responseData,
            ];

        } catch (\Exception $e) {
            Log::error('Chapa payment error: ' . $e->getMessage());
            return [
                'success' => false,
                'error' => 'Chapa service unavailable: ' . $e->getMessage()
            ];
        }
    }

    public function verifyTelebirrPayment($reference)
    {
        try {
            $payload = [
                'appId' => $this->telebirrConfig['api_key'],
                'outTradeNo' => $reference,
                'nonce' => Str::random(32),
                'timestamp' => time() * 1000,
            ];

            $payload['sign'] = $this->generateTelebirrSignature($payload);

            $response = Http::timeout(30)
                ->withHeaders([
                    'Content-Type' => 'application/json',
                ])
                ->post($this->telebirrConfig['base_url'] . '/payment/query', $payload);

            $responseData = $response->json();

            if ($response->successful() && isset($responseData['code']) && $responseData['code'] == '200') {
                $paymentData = $responseData['data'];
                $isPaid = $paymentData['tradeStatus'] === 'SUCCESS';

                return [
                    'success' => true,
                    'verified' => $isPaid,
                    'payment_data' => $paymentData,
                    'amount' => $paymentData['totalAmount'] ?? null,
                    'paid_at' => $paymentData['payTime'] ?? null,
                ];
            }

            return [
                'success' => false,
                'verified' => false,
                'error' => $responseData['message'] ?? 'Verification failed',
            ];

        } catch (\Exception $e) {
            Log::error('Telebirr verification error: ' . $e->getMessage());
            return [
                'success' => false,
                'verified' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    public function verifyCbeBirrPayment($reference)
    {
        try {
            $payload = [
                'merchantId' => $this->cbeBirrConfig['merchant_id'],
                'referenceNumber' => $reference,
                'transactionDateTime' => now()->format('YmdHis'),
            ];

            $payload['checkSum'] = $this->generateCbeBirrChecksum($payload);

            $response = Http::timeout(30)
                ->withHeaders([
                    'Authorization' => 'Bearer ' . $this->cbeBirrConfig['api_key'],
                    'Content-Type' => 'application/json',
                ])
                ->post($this->cbeBirrConfig['base_url'] . '/payment/verify', $payload);

            $responseData = $response->json();

            if ($response->successful() && isset($responseData['responseCode']) && $responseData['responseCode'] == '000') {
                return [
                    'success' => true,
                    'verified' => true,
                    'payment_data' => $responseData,
                    'amount' => $responseData['amount'] ?? null,
                    'paid_at' => $responseData['transactionDate'] ?? null,
                ];
            }

            return [
                'success' => false,
                'verified' => false,
                'error' => $responseData['responseDescription'] ?? 'Verification failed',
            ];

        } catch (\Exception $e) {
            Log::error('CBE Birr verification error: ' . $e->getMessage());
            return [
                'success' => false,
                'verified' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    public function verifyChapaPayment($reference)
    {
        try {
            $response = Http::timeout(30)
                ->withHeaders([
                    'Authorization' => 'Bearer ' . $this->chapaConfig['secret_key'],
                    'Content-Type' => 'application/json',
                ])
                ->get($this->chapaConfig['base_url'] . '/transaction/verify/' . $reference);

            $responseData = $response->json();

            if ($response->successful() && $responseData['status'] === 'success') {
                $paymentData = $responseData['data'];
                $isPaid = $paymentData['status'] === 'success';

                return [
                    'success' => true,
                    'verified' => $isPaid,
                    'payment_data' => $paymentData,
                    'amount' => $paymentData['amount'] ?? null,
                    'paid_at' => $paymentData['created_at'] ?? null,
                ];
            }

            return [
                'success' => false,
                'verified' => false,
                'error' => $responseData['message'] ?? 'Verification failed',
            ];

        } catch (\Exception $e) {
            Log::error('Chapa verification error: ' . $e->getMessage());
            return [
                'success' => false,
                'verified' => false,
                'error' => $e->getMessage(),
            ];
        }
    }
}