// app/Http/Kernel.php

protected $middlewareGroups = [
    'api' => [
        // ... other middleware
        \App\Http\Middleware\CheckShopActive::class,
    ],
];