<?php
// app/Http/Controllers/ReportController.php

namespace App\Http\Controllers;

use App\Models\Transaction;
use App\Models\Product;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class ReportController extends Controller
{
    public function salesSummary(Request $request)
    {
        $shopId = $request->user()->shop_id;
        $period = $request->get('period', 'today');
        
        $query = Transaction::where('shop_id', $shopId)
            ->where('status', 'completed');

        // Apply period filter
        $this->applyPeriodFilter($query, $period);

        $salesData = $query->selectRaw('
            COUNT(*) as total_transactions,
            SUM(total_amount) as total_sales,
            AVG(total_amount) as average_sale,
            SUM(tax_amount) as total_tax,
            SUM(discount_amount) as total_discount,
            MIN(total_amount) as min_sale,
            MAX(total_amount) as max_sale,
            SUM(paid_amount) as total_cash_in,
            SUM(change_amount) as total_change
        ')->first();

        $paymentMethods = $query->selectRaw('
            payment_method,
            COUNT(*) as transaction_count,
            SUM(total_amount) as total_amount
        ')->groupBy('payment_method')->get();

        // Hourly sales for the last 7 days
        $hourlySales = Transaction::where('shop_id', $shopId)
            ->where('status', 'completed')
            ->whereDate('created_at', '>=', now()->subDays(7))
            ->selectRaw('
                HOUR(created_at) as hour,
                COUNT(*) as transaction_count,
                SUM(total_amount) as total_amount
            ')
            ->groupBy('hour')
            ->orderBy('hour')
            ->get();

        return response()->json([
            'period' => $period,
            'sales_summary' => $salesData,
            'payment_methods' => $paymentMethods,
            'hourly_sales' => $hourlySales,
        ]);
    }

    public function topProducts(Request $request)
    {
        $shopId = $request->user()->shop_id;
        $limit = $request->get('limit', 10);
        $period = $request->get('period', 'month');

        $query = DB::table('transaction_items')
            ->join('transactions', 'transaction_items.transaction_id', '=', 'transactions.id')
            ->join('products', 'transaction_items.product_id', '=', 'products.id')
            ->where('transactions.shop_id', $shopId)
            ->where('transactions.status', 'completed');

        $this->applyPeriodFilter($query, $period, 'transactions.created_at');

        $topProducts = $query->selectRaw('
                products.id,
                products.name,
                products.barcode,
                products.category_id,
                SUM(transaction_items.quantity) as total_quantity,
                SUM(transaction_items.total_price) as total_revenue,
                AVG(transaction_items.unit_price) as average_price
            ')
            ->groupBy('products.id', 'products.name', 'products.barcode', 'products.category_id')
            ->orderByDesc('total_quantity')
            ->limit($limit)
            ->get();

        $lowStockProducts = Product::where('shop_id', $shopId)
            ->where('stock_quantity', '<=', DB::raw('min_stock'))
            ->where('is_active', true)
            ->select('id', 'name', 'barcode', 'stock_quantity', 'min_stock', 'price')
            ->get();

        return response()->json([
            'period' => $period,
            'top_products' => $topProducts,
            'low_stock_products' => $lowStockProducts,
        ]);
    }

    public function categorySales(Request $request)
    {
        $shopId = $request->user()->shop_id;
        $period = $request->get('period', 'month');

        $query = DB::table('transaction_items')
            ->join('transactions', 'transaction_items.transaction_id', '=', 'transactions.id')
            ->join('products', 'transaction_items.product_id', '=', 'products.id')
            ->join('categories', 'products.category_id', '=', 'categories.id')
            ->where('transactions.shop_id', $shopId)
            ->where('transactions.status', 'completed');

        $this->applyPeriodFilter($query, $period, 'transactions.created_at');

        $categorySales = $query->selectRaw('
                categories.id,
                categories.name,
                categories.color,
                COUNT(DISTINCT transactions.id) as transaction_count,
                SUM(transaction_items.quantity) as total_quantity,
                SUM(transaction_items.total_price) as total_revenue
            ')
            ->groupBy('categories.id', 'categories.name', 'categories.color')
            ->orderByDesc('total_revenue')
            ->get();

        return response()->json([
            'period' => $period,
            'category_sales' => $categorySales,
        ]);
    }

    public function exportSales(Request $request)
    {
        $request->validate([
            'date_from' => 'required|date',
            'date_to' => 'required|date|after_or_equal:date_from',
            'format' => 'in:csv,excel',
        ]);

        $shopId = $request->user()->shop_id;
        
        $transactions = Transaction::with(['items.product', 'user'])
            ->where('shop_id', $shopId)
            ->whereBetween('created_at', [$request->date_from, $request->date_to])
            ->get();

        if ($request->get('format') === 'csv') {
            return $this->exportToCsv($transactions, $request->date_from, $request->date_to);
        }

        // For Excel export, you would use a package like Maatwebsite/Laravel-Excel
        return response()->json([
            'message' => 'Excel export not implemented. Use CSV format.',
            'transactions' => $transactions
        ]);
    }

    private function applyPeriodFilter($query, $period, $dateColumn = 'created_at')
    {
        switch ($period) {
            case 'today':
                $query->whereDate($dateColumn, today());
                break;
            case 'yesterday':
                $query->whereDate($dateColumn, today()->subDay());
                break;
            case 'week':
                $query->whereBetween($dateColumn, [now()->startOfWeek(), now()->endOfWeek()]);
                break;
            case 'month':
                $query->whereMonth($dateColumn, now()->month)
                      ->whereYear($dateColumn, now()->year);
                break;
            case 'year':
                $query->whereYear($dateColumn, now()->year);
                break;
            case 'last_month':
                $query->whereMonth($dateColumn, now()->subMonth()->month)
                      ->whereYear($dateColumn, now()->subMonth()->year);
                break;
        }
    }

    private function exportToCsv($transactions, $dateFrom, $dateTo)
    {
        $fileName = "sales_report_{$dateFrom}_to_{$dateTo}.csv";
        
        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => "attachment; filename=\"$fileName\"",
        ];

        $callback = function () use ($transactions) {
            $file = fopen('php://output', 'w');
            
            // Header row
            fputcsv($file, [
                'Transaction ID', 'Date', 'Time', 'Cashier', 
                'Product', 'Quantity', 'Unit Price', 'Total', 
                'Payment Method', 'Status', 'Customer Phone'
            ]);

            // Data rows
            foreach ($transactions as $transaction) {
                foreach ($transaction->items as $item) {
                    fputcsv($file, [
                        $transaction->transaction_number,
                        $transaction->created_at->format('Y-m-d'),
                        $transaction->created_at->format('H:i:s'),
                        $transaction->user->name,
                        $item->product->name,
                        $item->quantity,
                        $item->unit_price,
                        $item->total_price,
                        $transaction->payment_method,
                        $transaction->status,
                        $transaction->customer_phone ?? '',
                    ]);
                }
            }

            fclose($file);
        };

        return response()->stream($callback, 200, $headers);
    }
}