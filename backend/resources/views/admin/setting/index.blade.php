{{-- // resources/views/admin/settings/index.blade.php --}}
@extends('layouts.admin')

@section('title', 'Settings')

@section('content')
    <div class="max-w-4xl mx-auto">
        <h1 class="text-2xl font-bold text-gray-900 mb-8">Shop Settings</h1>

        <div class="bg-white shadow rounded-lg">
            <!-- Shop Information -->
            <div class="px-6 py-4 border-b border-gray-200">
                <h3 class="text-lg font-medium text-gray-900">Shop Information</h3>
            </div>
            <div class="p-6">
                <form>
                    <div class="grid grid-cols-1 gap-6">
                        <div>
                            <label class="block text-sm font-medium text-gray-700">Shop Name</label>
                            <input type="text" value="{{ auth()->user()->shop->name }}" 
                                   class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                        </div>
                        
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label class="block text-sm font-medium text-gray-700">Phone</label>
                                <input type="text" value="{{ auth()->user()->shop->phone }}" 
                                       class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700">TIN Number</label>
                                <input type="text" value="{{ auth()->user()->shop->tin_number }}" 
                                       class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                            </div>
                        </div>
                        
                        <div>
                            <label class="block text-sm font-medium text-gray-700">Address</label>
                            <textarea rows="3" 
                                      class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500">{{ auth()->user()->shop->address }}</textarea>
                        </div>
                    </div>
                    
                    <div class="mt-6 flex justify-end">
                        <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700">
                            Save Changes
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- POS Settings -->
        <div class="bg-white shadow rounded-lg mt-6">
            <div class="px-6 py-4 border-b border-gray-200">
                <h3 class="text-lg font-medium text-gray-900">POS Settings</h3>
            </div>
            <div class="p-6">
                <form>
                    <div class="space-y-4">
                        <div class="flex items-center">
                            <input type="checkbox" id="print_receipt" class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                            <label for="print_receipt" class="ml-2 block text-sm text-gray-900">
                                Auto-print receipts after sale
                            </label>
                        </div>
                        
                        <div class="flex items-center">
                            <input type="checkbox" id="require_customer_info" class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                            <label for="require_customer_info" class="ml-2 block text-sm text-gray-900">
                                Require customer information for transactions
                            </label>
                        </div>
                        
                        <div>
                            <label class="block text-sm font-medium text-gray-700">Tax Rate (%)</label>
                            <input type="number" step="0.1" 
                                   class="mt-1 block w-32 border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                        </div>
                        
                        <div>
                            <label class="block text-sm font-medium text-gray-700">Low Stock Threshold</label>
                            <input type="number" 
                                   class="mt-1 block w-32 border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                        </div>
                    </div>
                    
                    <div class="mt-6 flex justify-end">
                        <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700">
                            Save Settings
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
@endsection