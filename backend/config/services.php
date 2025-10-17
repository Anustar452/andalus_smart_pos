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
    ],

    'cbe_birr' => [
        'base_url' => env('CBE_BIRR_BASE_URL', 'https://api.cbe.com.et/birr/v1'),
        'merchant_id' => env('CBE_BIRR_MERCHANT_ID'),
        'api_key' => env('CBE_BIRR_API_KEY'),
    ],

    'chapa' => [
        'base_url' => env('CHAPA_BASE_URL', 'https://api.chapa.com/v1'),
        'secret_key' => env('CHAPA_SECRET_KEY'),
    ],

];
