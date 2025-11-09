{{-- resources/views/admin/categories/index.blade.php --}}
@extends('layouts.admin')

@section('title', 'Categories Management')

@section('content')
<div class="flex justify-between items-center mb-6">
    <h1 class="text-2xl font-bold text-gray-900">Categories Management</h1>
    <button onclick="openAddCategoryModal()" 
            class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center">
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
        </svg>
        Add New Category
    </button>
</div>

<!-- Categories Grid -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
    @foreach($categories as $category)
        <div class="bg-white rounded-lg shadow p-6">
            <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-semibold text-gray-900">{{ $category->name }}</h3>
                <span class="px-2 py-1 text-xs font-medium rounded-full text-white" 
                      style="background-color: {{ $category->color }}">
                    {{ $category->products_count }} products
                </span>
            </div>
            
            @if($category->description)
                <p class="text-gray-600 text-sm mb-4">{{ $category->description }}</p>
            @endif
            
            <div class="flex items-center justify-between text-sm text-gray-500 mb-4">
                <span>
                    {{ $category->active_products_count }} active
                </span>
                <span>
                    Created {{ $category->created_at->diffForHumans() }}
                </span>
            </div>
            
            <div class="flex justify-between items-center">
                <span class="text-sm {{ $category->is_active ? 'text-green-600' : 'text-red-600' }}">
                    {{ $category->is_active ? 'Active' : 'Inactive' }}
                </span>
                <div class="flex space-x-2">
                    <button onclick="editCategory({{ $category->id }})" 
                            class="text-blue-600 hover:text-blue-900 text-sm flex items-center">
                        <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                        </svg>
                        Edit
                    </button>
                    <button onclick="deleteCategory({{ $category->id }})" 
                            class="text-red-600 hover:text-red-900 text-sm flex items-center">
                        <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                        </svg>
                        Delete
                    </button>
                </div>
            </div>
        </div>
    @endforeach

    @if($categories->isEmpty())
        <div class="col-span-3 text-center py-12">
            <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path>
            </svg>
            <h3 class="mt-2 text-sm font-medium text-gray-900">No categories</h3>
            <p class="mt-1 text-sm text-gray-500">Get started by creating a new category.</p>
            <div class="mt-6">
                <button onclick="openAddCategoryModal()" 
                        class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700">
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
                    </svg>
                    Add Category
                </button>
            </div>
        </div>
    @endif
</div>

<!-- Add Category Modal -->
<div id="addCategoryModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full hidden z-50">
    <div class="relative top-20 mx-auto p-5 border w-full max-w-md shadow-lg rounded-md bg-white">
        <div class="mt-3">
            <h3 class="text-lg font-medium text-gray-900 mb-4">Add New Category</h3>
            <form id="addCategoryForm">
                @csrf
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700">Category Name *</label>
                        <input type="text" name="name" required 
                               class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium text-gray-700">Description</label>
                        <textarea name="description" rows="3" 
                                  class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500"></textarea>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium text-gray-700">Color *</label>
                        <div class="mt-1 flex space-x-2">
                            <input type="color" name="color" value="#3B82F6" 
                                   class="h-10 w-10 border border-gray-300 rounded-md cursor-pointer">
                            <input type="text" name="color_hex" value="#3B82F6" 
                                   class="block w-32 border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                        </div>
                    </div>
                    
                    <div class="flex items-center">
                        <input type="checkbox" name="is_active" id="is_active" checked 
                               class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                        <label for="is_active" class="ml-2 block text-sm text-gray-900">
                            Active category
                        </label>
                    </div>
                </div>
                
                <div class="mt-6 flex justify-end space-x-3">
                    <button type="button" onclick="closeAddCategoryModal()" 
                            class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 border border-gray-300 rounded-md hover:bg-gray-200">
                        Cancel
                    </button>
                    <button type="submit" 
                            class="px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700">
                        Add Category
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function openAddCategoryModal() {
        document.getElementById('addCategoryModal').classList.remove('hidden');
    }

    function closeAddCategoryModal() {
        document.getElementById('addCategoryModal').classList.add('hidden');
        document.getElementById('addCategoryForm').reset();
    }

    // Update color hex when color picker changes
    document.querySelector('input[name="color"]').addEventListener('input', function(e) {
        document.querySelector('input[name="color_hex"]').value = e.target.value;
    });

    document.querySelector('input[name="color_hex"]').addEventListener('input', function(e) {
        document.querySelector('input[name="color"]').value = e.target.value;
    });

    // Form submission
    document.getElementById('addCategoryForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const data = Object.fromEntries(formData);

        try {
            const response = await fetch('/api/categories', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': '{{ csrf_token() }}',
                },
                body: JSON.stringify(data)
            });

            if (response.ok) {
                closeAddCategoryModal();
                location.reload();
            } else {
                const error = await response.json();
                alert('Error adding category: ' + (error.message || 'Unknown error'));
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Error adding category');
        }
    });
</script>
@endsection