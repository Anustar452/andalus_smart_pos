<?php
// app/Http/Controllers/Admin/ReportController.php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\Product;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReportController extends Controller
{
    public function index(Request $request)
    {
        $shopId = auth()->guard()->user()->shop_id;
        $period = $request->get('period', 'week');

        // Sales Summary
        $salesSummary = Transaction::where('shop_id', $shopId)
            ->where('status', 'completed')
            ->selectRaw('
                COUNT(*) as total_transactions,
                SUM(total_amount) as total_sales,
                AVG(total_amount) as average_sale
            ')
            ->first();

        // Sales Trend (Last 7 days)
        $salesTrend = Transaction::where('shop_id', $shopId)
            ->where('status', 'completed')
            ->whereDate('created_at', '>=', now()->subDays(7))
            ->selectRaw('
                DATE(created_at) as date,
                COUNT(*) as transaction_count,
                SUM(total_amount) as total_sales,
                AVG(total_amount) as average_sale
            ')
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        // Payment Methods
        $paymentMethods = Transaction::where('shop_id', $shopId)
            ->where('status', 'completed')
            ->selectRaw('
                payment_method,
                COUNT(*) as transaction_count,
                SUM(total_amount) as total_amount
            ')
            ->groupBy('payment_method')
            ->get();

        // Top Products
        $topProducts = DB::table('transaction_items')
            ->join('transactions', 'transaction_items.transaction_id', '=', 'transactions.id')
            ->join('products', 'transaction_items.product_id', '=', 'products.id')
            ->where('transactions.shop_id', $shopId)
            ->where('transactions.status', 'completed')
            ->selectRaw('
                products.name,
                SUM(transaction_items.quantity) as total_quantity,
                SUM(transaction_items.total_price) as total_revenue,
                AVG(transaction_items.unit_price) as average_price
            ')
            ->groupBy('products.id', 'products.name')
            ->orderByDesc('total_quantity')
            ->limit(5)
            ->get();

        // Category Sales
        $categorySales = DB::table('transaction_items')
            ->join('transactions', 'transaction_items.transaction_id', '=', 'transactions.id')
            ->join('products', 'transaction_items.product_id', '=', 'products.id')
            ->join('categories', 'products.category_id', '=', 'categories.id')
            ->where('transactions.shop_id', $shopId)
            ->where('transactions.status', 'completed')
            ->selectRaw('
                categories.name,
                categories.color,
                SUM(transaction_items.quantity) as total_quantity,
                SUM(transaction_items.total_price) as total_revenue
            ')
            ->groupBy('categories.id', 'categories.name', 'categories.color')
            ->orderByDesc('total_revenue')
            ->get();

        // Daily Sales
        $dailySales = Transaction::where('shop_id', $shopId)
            ->where('status', 'completed')
            ->whereDate('created_at', '>=', now()->subDays(30))
            ->selectRaw('
                DATE(created_at) as date,
                COUNT(*) as transaction_count,
                SUM(total_amount) as total_sales,
                AVG(total_amount) as average_sale
            ')
            ->groupBy('date')
            ->orderBy('date', 'desc')
            ->get();

        // Total Products Sold
        $totalProductsSold = DB::table('transaction_items')
            ->join('transactions', 'transaction_items.transaction_id', '=', 'transactions.id')
            ->where('transactions.shop_id', $shopId)
            ->where('transactions.status', 'completed')
            ->sum('transaction_items.quantity');

        return view('admin.reports.index', compact(
            'salesSummary',
            'salesTrend',
            'paymentMethods',
            'topProducts',
            'categorySales',
            'dailySales',
            'totalProductsSold'
        ));
    }
}