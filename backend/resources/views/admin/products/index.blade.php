{{-- resources/views/admin/products/index.blade.php --}}
@extends('layouts.admin')

@section('title', 'Products Management')

@section('content')
<div class="flex justify-between items-center mb-6">
    <h1 class="text-2xl font-bold text-gray-900">Products Management</h1>
    <button onclick="openAddProductModal()" 
            class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center">
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
        </svg>
        Add New Product
    </button>
</div>

<!-- Search and Filters -->
<div class="bg-white rounded-lg shadow p-4 mb-6">
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div>
            <input type="text" id="searchInput" placeholder="Search products..." 
                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-blue-500 focus:border-blue-500">
        </div>
        <div>
            <select id="categoryFilter" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                <option value="">All Categories</option>
                @foreach($categories as $category)
                    <option value="{{ $category->id }}">{{ $category->name }}</option>
                @endforeach
            </select>
        </div>
        <div>
            <select id="statusFilter" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                <option value="">All Status</option>
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
                <option value="low_stock">Low Stock</option>
            </select>
        </div>
        <div>
            <button onclick="exportProducts()" class="w-full bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700 flex items-center justify-center">
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                </svg>
                Export
            </button>
        </div>
    </div>
</div>

<!-- Products Table -->
<div class="bg-white rounded-lg shadow overflow-hidden">
    <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Product
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Barcode
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Category
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Price
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Stock
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Status
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Actions
                    </th>
                </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200" id="productsTableBody">
                @foreach($products as $product)
                    <tr>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <div class="flex items-center">
                                @if($product->image)
                                    <img class="h-10 w-10 rounded-lg object-cover" src="{{ Storage::url($product->image) }}" alt="{{ $product->name }}">
                                @else
                                    <div class="h-10 w-10 rounded-lg bg-gray-200 flex items-center justify-center">
                                        <svg class="h-6 w-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"></path>
                                        </svg>
                                    </div>
                                @endif
                                <div class="ml-4">
                                    <div class="text-sm font-medium text-gray-900">{{ $product->name }}</div>
                                    @if($product->description)
                                        <div class="text-sm text-gray-500 truncate max-w-xs">{{ $product->description }}</div>
                                    @endif
                                </div>
                            </div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            {{ $product->barcode ?? 'N/A' }}
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            @if($product->category)
                                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium text-white" style="background-color: {{ $product->category->color }}">
                                    {{ $product->category->name }}
                                </span>
                            @else
                                <span class="text-gray-400">No category</span>
                            @endif
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            {{ number_format($product->price, 2) }} ETB
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm {{ $product->stock_quantity <= $product->min_stock ? 'text-red-600 font-semibold' : 'text-gray-500' }}">
                            {{ $product->stock_quantity }}
                            @if($product->stock_quantity <= $product->min_stock)
                                <span class="bg-red-100 text-red-800 text-xs px-2 py-1 rounded ml-2">Low Stock</span>
                            @endif
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full {{ $product->is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800' }}">
                                {{ $product->is_active ? 'Active' : 'Inactive' }}
                            </span>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                            <div class="flex space-x-2">
                                <button onclick="editProduct({{ $product->id }})" 
                                        class="text-blue-600 hover:text-blue-900 flex items-center">
                                    <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                                    </svg>
                                    Edit
                                </button>
                                <button onclick="adjustStock({{ $product->id }})" 
                                        class="text-green-600 hover:text-green-900 flex items-center">
                                    <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v3m0 0v3m0-3h3m-3 0H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                    </svg>
                                    Stock
                                </button>
                                <button onclick="toggleProductStatus({{ $product->id }})" 
                                        class="text-yellow-600 hover:text-yellow-900 flex items-center">
                                    <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                    </svg>
                                    {{ $product->is_active ? 'Deactivate' : 'Activate' }}
                                </button>
                            </div>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>
    
    <!-- Pagination -->
    <div class="bg-white px-4 py-3 border-t border-gray-200 sm:px-6">
        <div class="flex justify-between items-center">
            <div class="text-sm text-gray-700">
                Showing <span>{{ $products->firstItem() }}</span> to <span>{{ $products->lastItem() }}</span> of <span>{{ $products->total() }}</span> results
            </div>
            <div class="flex space-x-2">
                @if($products->onFirstPage())
                    <span class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-400 bg-gray-50 cursor-not-allowed">
                        Previous
                    </span>
                @else
                    <a href="{{ $products->previousPageUrl() }}" class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50">
                        Previous
                    </a>
                @endif

                @if($products->hasMorePages())
                    <a href="{{ $products->nextPageUrl() }}" class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50">
                        Next
                    </a>
                @else
                    <span class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-400 bg-gray-50 cursor-not-allowed">
                        Next
                    </span>
                @endif
            </div>
        </div>
    </div>
</div>

<!-- Add Product Modal -->
<div id="addProductModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full hidden z-50">
    <div class="relative top-20 mx-auto p-5 border w-full max-w-2xl shadow-lg rounded-md bg-white">
        <div class="mt-3">
            <h3 class="text-lg font-medium text-gray-900 mb-4">Add New Product</h3>
            
            <form id="addProductForm" enctype="multipart/form-data">
                @csrf
                <div class="grid grid-cols-1 gap-4 mb-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700">Product Name *</label>
                        <input type="text" name="name" required 
                               class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                    </div>
                    
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-700">Barcode</label>
                            <input type="text" name="barcode" 
                                   class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700">Category</label>
                            <select name="category_id" class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                                <option value="">Select Category</option>
                                @foreach($categories as $category)
                                    <option value="{{ $category->id }}">{{ $category->name }}</option>
                                @endforeach
                            </select>
                        </div>
                    </div>
                    
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-700">Price (ETB) *</label>
                            <input type="number" name="price" step="0.01" min="0" required 
                                   class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700">Cost Price (ETB)</label>
                            <input type="number" name="cost_price" step="0.01" min="0" 
                                   class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                        </div>
                    </div>
                    
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-700">Stock Quantity *</label>
                            <input type="number" name="stock_quantity" min="0" required 
                                   class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700">Min Stock *</label>
                            <input type="number" name="min_stock" min="0" required 
                                   class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                        </div>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium text-gray-700">Description</label>
                        <textarea name="description" rows="3" 
                                  class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500"></textarea>
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700">Product Image</label>
                        <input type="file" name="image" accept="image/*" 
                               class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                    </div>
                </div>
                
                <div class="flex justify-end space-x-3">
                    <button type="button" onclick="closeAddProductModal()" 
                            class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 border border-gray-300 rounded-md hover:bg-gray-200">
                        Cancel
                    </button>
                    <button type="submit" 
                            class="px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700">
                        Add Product
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function openAddProductModal() {
        document.getElementById('addProductModal').classList.remove('hidden');
    }

    function closeAddProductModal() {
        document.getElementById('addProductModal').classList.add('hidden');
        document.getElementById('addProductForm').reset();
    }

    function exportProducts() {
        // Implement export functionality
        alert('Export functionality will be implemented soon!');
    }

    // Form submission
    document.getElementById('addProductForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);

        try {
            const response = await fetch('/api/products', {
                method: 'POST',
                headers: {
                    'X-CSRF-TOKEN': '{{ csrf_token() }}',
                },
                body: formData
            });

            if (response.ok) {
                closeAddProductModal();
                location.reload(); // Reload to show new product
            } else {
                const error = await response.json();
                alert('Error adding product: ' + (error.message || 'Unknown error'));
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Error adding product');
        }
    });
</script>
@endsection