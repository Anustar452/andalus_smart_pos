<?php
// app/Http/Controllers/CategoryController.php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Http\Resources\CategoryResource;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
class CategoryController extends Controller
{
    use AuthorizesRequests;

    public function index(Request $request)
    {
        $categories = Category::where('shop_id', $request->user()->shop_id)
            ->withCount('products')
            ->orderBy('name')
            ->get();

        return CategoryResource::collection($categories);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('categories')->where(function ($query) use ($request) {
                    return $query->where('shop_id', $request->user()->shop_id);
                })
            ],
            'description' => 'nullable|string',
            'color' => 'nullable|string|max:7',
            'is_active' => 'boolean',
        ]);

        $validated['shop_id'] = $request->user()->shop_id;
        $validated['color'] = $validated['color'] ?? '#'.dechex(rand(0x000000, 0xFFFFFF));

        $category = Category::create($validated);

        return new CategoryResource($category);
    }

    public function show(Category $category)
    {
        $this->authorize('view', $category);
        return new CategoryResource($category->load('products'));
    }

    public function update(Request $request, Category $category)
    {
        $this->authorize('update', $category);

        $validated = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('categories')->where(function ($query) use ($request, $category) {
                    return $query->where('shop_id', $request->user()->shop_id)
                                ->where('id', '!=', $category->id);
                })
            ],
            'description' => 'nullable|string',
            'color' => 'nullable|string|max:7',
            'is_active' => 'boolean',
        ]);

        $category->update($validated);

        return new CategoryResource($category);
    }

    public function destroy(Category $category)
    {
        $this->authorize('delete', $category);

        // Check if category has products
        if ($category->products()->exists()) {
            return response()->json([
                'message' => 'Cannot delete category with products. Please reassign or delete the products first.'
            ], 422);
        }

        $category->delete();

        return response()->json(['message' => 'Category deleted successfully']);
    }
}