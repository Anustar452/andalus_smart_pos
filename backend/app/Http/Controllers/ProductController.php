<?php
// app/Http/Controllers/ProductController.php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Models\Category;
use App\Models\StockMovement;
use App\Http\Resources\ProductResource;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
class ProductController extends Controller
{
    use AuthorizesRequests;


    public function index(Request $request)
    {
        $query = Product::with('category')
            ->where('shop_id', $request->user()->shop_id);

        // Search functionality
        if ($request->has('search') && $request->search) {
            $query->search($request->search);
        }

        // Filter by category
        if ($request->has('category_id') && $request->category_id) {
            $query->where('category_id', $request->category_id);
        }

        // Filter by status
        if ($request->has('status')) {
            if ($request->status === 'active') {
                $query->active();
            } elseif ($request->status === 'inactive') {
                $query->where('is_active', false);
            } elseif ($request->status === 'low_stock') {
                $query->lowStock();
            }
        }

        $products = $query->orderBy('name')->paginate(50);

        return ProductResource::collection($products);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'category_id' => 'nullable|exists:categories,id',
            'barcode' => [
                'nullable',
                'string',
                Rule::unique('products')->where(function ($query) use ($request) {
                    return $query->where('shop_id', $request->user()->shop_id);
                })
            ],
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'cost_price' => 'nullable|numeric|min:0',
            'stock_quantity' => 'required|integer|min:0',
            'min_stock' => 'required|integer|min:0',
            'image' => 'nullable|string',
            'is_active' => 'boolean',
        ]);

        $validated['shop_id'] = $request->user()->shop_id;

        $product = Product::create($validated);

        // Record initial stock movement if stock is added
        if ($validated['stock_quantity'] > 0) {
            StockMovement::recordMovement(
                $product,
                'in',
                $validated['stock_quantity'],
                $request->user(),
                'Initial stock'
            );
        }

        return new ProductResource($product->load('category'));
    }

    public function show(Product $product)
    {
        $this->authorize('view', $product);
        return new ProductResource($product->load(['category', 'stockMovements.user']));
    }

    public function update(Request $request, Product $product)
    {
        $this->authorize('update', $product);

        $validated = $request->validate([
            'category_id' => 'nullable|exists:categories,id',
            'barcode' => [
                'nullable',
                'string',
                Rule::unique('products')->where(function ($query) use ($request, $product) {
                    return $query->where('shop_id', $request->user()->shop_id)
                                ->where('id', '!=', $product->id);
                })
            ],
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'cost_price' => 'nullable|numeric|min:0',
            'min_stock' => 'required|integer|min:0',
            'image' => 'nullable|string',
            'is_active' => 'boolean',
        ]);

        $product->update($validated);

        return new ProductResource($product->load('category'));
    }

    public function destroy(Product $product)
    {
        $this->authorize('delete', $product);

        // Check if product has transactions
        if ($product->transactionItems()->exists()) {
            return response()->json([
                'message' => 'Cannot delete product with transaction history. You can deactivate it instead.'
            ], 422);
        }

        $product->delete();

        return response()->json(['message' => 'Product deleted successfully']);
    }

    public function adjustStock(Request $request, Product $product)
    {
        $this->authorize('update', $product);

        $validated = $request->validate([
            'type' => 'required|in:in,out,adjustment',
            'quantity' => 'required|integer|min:1',
            'reason' => 'required|string|max:500',
        ]);

        $movement = StockMovement::recordMovement(
            $product,
            $validated['type'],
            $validated['quantity'],
            $request->user(),
            $validated['reason']
        );

        return response()->json([
            'message' => 'Stock adjusted successfully',
            'product' => new ProductResource($product->fresh()),
            'movement' => $movement,
        ]);
    }

    public function searchByBarcode(Request $request, $barcode)
    {
        $product = Product::with('category')
            ->where('shop_id', $request->user()->shop_id)
            ->where('barcode', $barcode)
            ->active()
            ->first();

        if (!$product) {
            return response()->json([
                'message' => 'Product not found'
            ], 404);
        }

        return new ProductResource($product);
    }
}