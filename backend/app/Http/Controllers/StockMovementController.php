<?php
// app/Http/Controllers/StockMovementController.php

namespace App\Http\Controllers;

use App\Models\StockMovement;
use App\Models\Product;
use App\Http\Resources\StockMovementResource;
use Illuminate\Http\Request;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;


class StockMovementController extends Controller
{
    use AuthorizesRequests;

    public function index(Request $request)
    {
        $query = StockMovement::with(['product', 'user'])
            ->whereHas('product', function ($q) use ($request) {
                $q->where('shop_id', $request->user()->shop_id);
            })
            ->orderBy('created_at', 'desc');

        // Filter by date range
        if ($request->has('date_from')) {
            $query->whereDate('created_at', '>=', $request->date_from);
        }

        if ($request->has('date_to')) {
            $query->whereDate('created_at', '<=', $request->date_to);
        }

        // Filter by type
        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        // Filter by product
        if ($request->has('product_id')) {
            $query->where('product_id', $request->product_id);
        }

        $movements = $query->paginate(50);

        return StockMovementResource::collection($movements);
    }

    public function show(StockMovement $stockMovement)
    {
        $this->authorize('view', $stockMovement);
        return new StockMovementResource($stockMovement->load(['product', 'user']));
    }

    public function productMovements(Request $request, Product $product)
    {
        $this->authorize('view', $product);

        $movements = StockMovement::with('user')
            ->where('product_id', $product->id)
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return StockMovementResource::collection($movements);
    }

    public function stockReport(Request $request)
    {
        $shopId = $request->user()->shop_id;

        // Stock summary
        $stockSummary = Product::where('shop_id', $shopId)
            ->selectRaw('
                COUNT(*) as total_products,
                SUM(stock_quantity) as total_stock_value,
                SUM(CASE WHEN stock_quantity <= min_stock THEN 1 ELSE 0 END) as low_stock_count,
                SUM(CASE WHEN stock_quantity = 0 THEN 1 ELSE 0 END) as out_of_stock_count
            ')
            ->first();

        // Recent stock movements
        $recentMovements = StockMovement::with(['product', 'user'])
            ->whereHas('product', function ($q) use ($shopId) {
                $q->where('shop_id', $shopId);
            })
            ->orderBy('created_at', 'desc')
            ->limit(10)
            ->get();

        // Stock movements by type
        $movementsByType = StockMovement::whereHas('product', function ($q) use ($shopId) {
                $q->where('shop_id', $shopId);
            })
            ->selectRaw('type, COUNT(*) as count, SUM(quantity) as total_quantity')
            ->groupBy('type')
            ->get();

        return response()->json([
            'stock_summary' => $stockSummary,
            'recent_movements' => StockMovementResource::collection($recentMovements),
            'movements_by_type' => $movementsByType,
        ]);
    }
}