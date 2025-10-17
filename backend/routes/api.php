<?php
// routes/api.php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\TransactionController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\ShopController;
use App\Http\Controllers\DashboardController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Payment callbacks (public routes)
Route::post('/payment/telebirr/callback', [PaymentController::class, 'telebirrCallback']);
Route::post('/payment/cbe-birr/callback', [PaymentController::class, 'cbeBirrCallback']);
Route::post('/payment/chapa/callback', [PaymentController::class, 'chapaCallback']);

Route::middleware('auth:sanctum')->group(function () {
    // Auth routes
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);

    // Dashboard
    Route::get('/dashboard/overview', [DashboardController::class, 'overview']);
    Route::get('/dashboard/analytics', [DashboardController::class, 'salesAnalytics']);

    // Shop management
    Route::get('/shop', [ShopController::class, 'show']);
    Route::put('/shop', [ShopController::class, 'update']);
    Route::post('/shop/logo', [ShopController::class, 'uploadLogo']);
    Route::post('/shop/settings', [ShopController::class, 'updateSettings']);

    // Products
    Route::apiResource('products', ProductController::class);
    Route::post('products/{product}/adjust-stock', [ProductController::class, 'adjustStock']);
    Route::get('products/search/{barcode}', [ProductController::class, 'searchByBarcode']);

    // Categories
    Route::apiResource('categories', CategoryController::class);

    // Transactions
    Route::apiResource('transactions', TransactionController::class);
    Route::post('transactions/{transaction}/refund', [TransactionController::class, 'refund']);
    Route::get('transactions/daily-summary', [TransactionController::class, 'dailySummary']);
    Route::get('transactions/{transaction}/verify-payment', [PaymentController::class, 'verifyPayment']);

    // Reports
    Route::prefix('reports')->group(function () {
        Route::get('sales-summary', [ReportController::class, 'salesSummary']);
        Route::get('top-products', [ReportController::class, 'topProducts']);
        Route::get('category-sales', [ReportController::class, 'categorySales']);
        Route::get('export-sales', [ReportController::class, 'exportSales']);
    });

    // Users
    Route::apiResource('users', UserController::class);
    Route::post('users/{user}/update-password', [UserController::class, 'updatePassword']);
    Route::post('users/{user}/toggle-status', [UserController::class, 'toggleStatus']);
});