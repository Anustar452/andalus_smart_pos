<?php
// app/Http/Controllers/DashboardController.php

namespace App\Http\Controllers;

use App\Models\Transaction;
use App\Models\Product;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class DashboardController extends Controller
{
    public function overview(Request $request)
    {
        $shopId = $request->user()->shop_id;
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

        // Weekly sales trend
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

        // Top selling products today
        $topProductsToday = DB::table('transaction_items')
            ->join('transactions', 'transaction_items.transaction_id', '=', 'transactions.id')
            ->join('products', 'transaction_items.product_id', '=', 'products.id')
            ->where('transactions.shop_id', $shopId)
            ->where('transactions.status', 'completed')
            ->whereDate('transactions.created_at', $today)
            ->selectRaw('
                products.name,
                SUM(transaction_items.quantity) as total_quantity,
                SUM(transaction_items.total_price) as total_revenue
            ')
            ->groupBy('products.id', 'products.name')
            ->orderByDesc('total_quantity')
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

        return response()->json([
            'today_sales' => $todaySales,
            'weekly_sales_trend' => $weeklySales,
            'low_stock_products_count' => $lowStockProducts,
            'top_products_today' => $topProductsToday,
            'payment_methods_summary' => $paymentMethods,
        ]);
    }

    public function salesAnalytics(Request $request)
    {
        $shopId = $request->user()->shop_id;
        $period = $request->get('period', 'week'); // week, month, year

        $query = Transaction::where('shop_id', $shopId)
            ->where('status', 'completed');

        if ($period === 'week') {
            $query->whereDate('created_at', '>=', now()->subDays(7))
                  ->selectRaw('DAYNAME(created_at) as period, 
                              DATE(created_at) as date,
                              COUNT(*) as transaction_count,
                              SUM(total_amount) as total_sales')
                  ->groupBy('period', 'date');
        } elseif ($period === 'month') {
            $query->whereMonth('created_at', now()->month)
                  ->whereYear('created_at', now()->year)
                  ->selectRaw('WEEK(created_at) as period,
                              COUNT(*) as transaction_count,
                              SUM(total_amount) as total_sales')
                  ->groupBy('period');
        } else { // year
            $query->whereYear('created_at', now()->year)
                  ->selectRaw('MONTHNAME(created_at) as period,
                              MONTH(created_at) as month_num,
                              COUNT(*) as transaction_count,
                              SUM(total_amount) as total_sales')
                  ->groupBy('period', 'month_num')
                  ->orderBy('month_num');
        }

        $salesData = $query->get();

        // Compare with previous period
        $previousPeriodData = $this->getPreviousPeriodData($shopId, $period);

        return response()->json([
            'period' => $period,
            'current_period' => $salesData,
            'previous_period' => $previousPeriodData,
            'growth_rate' => $this->calculateGrowthRate($salesData, $previousPeriodData),
        ]);
    }

    private function getPreviousPeriodData($shopId, $period)
    {
        $query = Transaction::where('shop_id', $shopId)
            ->where('status', 'completed');

        if ($period === 'week') {
            $query->whereDate('created_at', '>=', now()->subDays(14))
                  ->whereDate('created_at', '<', now()->subDays(7))
                  ->selectRaw('DAYNAME(created_at) as period,
                              DATE(created_at) as date,
                              SUM(total_amount) as total_sales')
                  ->groupBy('period', 'date');
        } elseif ($period === 'month') {
            $query->whereMonth('created_at', now()->subMonth()->month)
                  ->whereYear('created_at', now()->subMonth()->year)
                  ->selectRaw('WEEK(created_at) as period,
                              SUM(total_amount) as total_sales')
                  ->groupBy('period');
        } else {
            $query->whereYear('created_at', now()->subYear()->year)
                  ->selectRaw('MONTHNAME(created_at) as period,
                              MONTH(created_at) as month_num,
                              SUM(total_amount) as total_sales')
                  ->groupBy('period', 'month_num')
                  ->orderBy('month_num');
        }

        return $query->get();
    }

    private function calculateGrowthRate($current, $previous)
    {
        $currentTotal = $current->sum('total_sales');
        $previousTotal = $previous->sum('total_sales');

        if ($previousTotal == 0) {
            return $currentTotal > 0 ? 100 : 0;
        }

        return (($currentTotal - $previousTotal) / $previousTotal) * 100;
    }
}