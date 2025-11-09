<?php
// app/Http/Controllers/Admin/DashboardController.php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\Product;
use App\Models\User;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function index()
    {
        $user = \Illuminate\Support\Facades\Auth::user();
        if (!$user) {
            abort(403, 'Unauthorized access');
        }
        $shop = $user->shop;
        $shopId = $shop->id;
        $today = now()->format('Y-m-d');

        // Today's sales summary
        $todaySales = Transaction::where('shop_id', $shopId)
            ->whereDate('created_at', $today)
            ->where('status', 'completed')
            ->selectRaw('
                COUNT(*) as transaction_count,
                SUM(total_amount) as total_sales,
                SUM(paid_amount) as total_cash_in,
                SUM(change_amount) as total_change
            ')
            ->first();

        // Weekly sales trend (last 7 days)
        $weeklySales = Transaction::where('shop_id', $shopId)
            ->where('status', 'completed')
            ->whereDate('created_at', '>=', now()->subDays(7))
            ->selectRaw('
                DATE(created_at) as date,
                COUNT(*) as transaction_count,
                SUM(total_amount) as total_sales
            ')
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        // Low stock products
        $lowStockProducts = Product::where('shop_id', $shopId)
            ->where('is_active', true)
            ->whereRaw('stock_quantity <= min_stock')
            ->count();

        // Total products
        $totalProducts = Product::where('shop_id', $shopId)
            ->where('is_active', true)
            ->count();

        // Total categories
        $totalCategories = Category::where('shop_id', $shopId)
            ->where('is_active', true)
            ->count();

        // Recent transactions
        $recentTransactions = Transaction::with('user')
            ->where('shop_id', $shopId)
            ->orderBy('created_at', 'desc')
            ->limit(10)
            ->get();

        // Top products (low stock)
        $topProducts = Product::where('shop_id', $shopId)
            ->where('is_active', true)
            ->orderBy('stock_quantity', 'asc')
            ->limit(5)
            ->get();

        // Payment methods summary
        $paymentMethods = Transaction::where('shop_id', $shopId)
            ->where('status', 'completed')
            ->whereDate('created_at', $today)
            ->selectRaw('
                payment_method,
                COUNT(*) as transaction_count,
                SUM(total_amount) as total_amount
            ')
            ->groupBy('payment_method')
            ->get();

        return view('admin.dashboard', [
            'shop' => $shop,
            'todaySales' => $todaySales,
            'weeklySales' => $weeklySales,
            'lowStockProducts' => $lowStockProducts,
            'totalProducts' => $totalProducts,
            'totalCategories' => $totalCategories,
            'recentTransactions' => $recentTransactions,
            'topProducts' => $topProducts,
            'paymentMethods' => $paymentMethods,
        ]);
    }
}