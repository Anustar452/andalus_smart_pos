<?php
// app/Http/Controllers/Admin/ProductController.php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\Category;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function index()
    {
        $products = Product::with('category')
            ->where('shop_id', auth()->guard()->user()->shop_id)
            ->orderBy('name')
            ->paginate(20);

        $categories = Category::where('shop_id', auth()->guard()->user()->shop_id)
            ->where('is_active', true)
            ->orderBy('name')
            ->get();

        return view('admin.products.index', compact('products', 'categories'));
    }
}