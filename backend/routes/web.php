<?php
// routes/web.php

use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\ProductController;
use App\Http\Controllers\TransactionController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\Admin\CategoryController;
use App\Http\Controllers\Admin\SettingController;
use App\Http\Controllers\Admin\StockController;
use App\Http\Controllers\UserController;
use Illuminate\Support\Facades\Route;

// Admin Authentication Routes
Route::get('/admin/login', [AuthController::class, 'showLoginForm'])->name('admin.login');
Route::post('/admin/login', [AuthController::class, 'login'])->name('admin.login.post');
Route::post('/admin/logout', [AuthController::class, 'logout'])->name('admin.logout');

// Admin Protected Routes
Route::middleware(['auth'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/stock', [StockController::class, 'index'])->name('stock');
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
    Route::get('/products', [ProductController::class, 'index'])->name('products');
    Route::get('/categories', [CategoryController::class, 'index'])->name('categories');
    Route::get('/transactions', [TransactionController::class, 'index'])->name('transactions');
    Route::get('/reports', [ReportController::class, 'index'])->name('reports');
    Route::get('/users', [UserController::class, 'index'])->name('users');
    Route::get('/settings', [SettingController::class, 'index'])->name('settings');
});

// Redirect root to admin login
Route::redirect('/', '/admin/login');


// routes/web.php
Route::middleware(['auth'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
    Route::get('/products', [ProductController::class, 'index'])->name('products');
    Route::get('/categories', [CategoryController::class, 'index'])->name('categories');
    Route::get('/transactions', [TransactionController::class, 'index'])->name('transactions');
    Route::get('/reports', [ReportController::class, 'index'])->name('reports');
    Route::get('/users', [UserController::class, 'index'])->name('users');
    Route::get('/settings', [SettingController::class, 'index'])->name('settings');
});