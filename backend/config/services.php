<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'token' => env('POSTMARK_TOKEN'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'resend' => [
        'key' => env('RESEND_KEY'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],
     'telebirr' => [
        'base_url' => env('TELEBIRR_BASE_URL', 'https://api.telebirr.com/v1'),
        'api_key' => env('TELEBIRR_API_KEY'),
        'secret_key' => env('TELEBIRR_SECRET_KEY'),
        'merchant_id' => env('TELEBIRR_MERCHANT_ID'),
    ],

    'cbe_birr' => [
        'base_url' => env('CBE_BIRR_BASE_URL', 'https://api.cbe.com.et/birr/v1'),
        'merchant_id' => env('CBE_BIRR_MERCHANT_ID'),
        'api_key' => env('CBE_BIRR_API_KEY'),
        'terminal_id' => env('CBE_BIRR_TERMINAL_ID'),
    ],

    'chapa' => [
        'base_url' => env('CHAPA_BASE_URL', 'https://api.chapa.com/v1'),
        'secret_key' => env('CHAPA_SECRET_KEY'),
        'public_key' => env('CHAPA_PUBLIC_KEY'),
    ],

    'firebase' => [
        'project_id' => env('FIREBASE_PROJECT_ID'),
        'private_key_id' => env('FIREBASE_PRIVATE_KEY_ID'),
        'private_key' => env('FIREBASE_PRIVATE_KEY'),
        'client_email' => env('FIREBASE_CLIENT_EMAIL'),
        'client_id' => env('FIREBASE_CLIENT_ID'),
        'client_x509_cert_url' => env('FIREBASE_CLIENT_X509_CERT_URL'),
    ],


];
