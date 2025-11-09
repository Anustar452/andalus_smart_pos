<?php
// app/Http/Controllers/Admin/StockController.php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\StockMovement;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class StockController extends Controller
{
    public function index()
    {
        $shopId = auth()->guard()->user()->shop_id;

        $totalProducts = Product::where('shop_id', $shopId)->count();
        $lowStockCount = Product::where('shop_id', $shopId)
            ->whereRaw('stock_quantity <= min_stock')
            ->where('is_active', true)
            ->count();
        $outOfStockCount = Product::where('shop_id', $shopId)
            ->where('stock_quantity', 0)
            ->where('is_active', true)
            ->count();
        $totalStockValue = Product::where('shop_id', $shopId)
            ->where('is_active', true)
            ->sum(DB::raw('stock_quantity * cost_price'));

        $recentMovements = StockMovement::with('product')
            ->whereHas('product', function($query) use ($shopId) {
                $query->where('shop_id', $shopId);
            })
            ->orderBy('created_at', 'desc')
            ->limit(10)
            ->get();

        $lowStockProducts = Product::with('category')
            ->where('shop_id', $shopId)
            ->whereRaw('stock_quantity <= min_stock')
            ->where('is_active', true)
            ->orderBy('stock_quantity', 'asc')
            ->get();

        $categories = Category::where('shop_id', $shopId)
            ->where('is_active', true)
            ->get();

        return view('admin.stock.index', compact(
            'totalProducts',
            'lowStockCount',
            'outOfStockCount',
            'totalStockValue',
            'recentMovements',
            'lowStockProducts',
            'categories'
        ));
    }
}