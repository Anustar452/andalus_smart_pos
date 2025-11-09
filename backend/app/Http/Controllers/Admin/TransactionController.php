<?php
// app/Http/Controllers/Admin/TransactionController.php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Http\Request;

class TransactionController extends Controller
{
    public function index(Request $request)
    {
        $query = Transaction::with(['user', 'items.product'])
            ->where('shop_id', auth()->guard()->user()->shop_id)
            ->orderBy('created_at', 'desc');

        // Apply filters
        if ($request->has('date_from')) {
            $query->whereDate('created_at', '>=', $request->date_from);
        }

        if ($request->has('date_to')) {
            $query->whereDate('created_at', '<=', $request->date_to);
        }

        if ($request->has('payment_method')) {
            $query->where('payment_method', $request->payment_method);
        }

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        $transactions = $query->paginate(20);

        // Statistics
        $totalSales = Transaction::where('shop_id', auth()->guard()->user()->shop_id)
            ->where('status', 'completed')
            ->sum('total_amount');

        $totalTransactions = Transaction::where('shop_id', auth()->guard()->user()->shop_id)->count();
        
        $averageSale = $totalTransactions > 0 ? $totalSales / $totalTransactions : 0;
        
        $refundCount = Transaction::where('shop_id', auth()->guard()->user()->shop_id)
            ->where('status', 'refunded')
            ->count();

        return view('admin.transactions.index', compact(
            'transactions', 
            'totalSales', 
            'totalTransactions', 
            'averageSale', 
            'refundCount'
        ));
    }
}