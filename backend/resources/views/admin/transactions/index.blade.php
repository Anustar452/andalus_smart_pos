{{-- resources/views/admin/transactions/index.blade.php --}}
@extends('layouts.admin')

@section('title', 'Transactions')

@section('content')
<div class="flex justify-between items-center mb-6">
    <h1 class="text-2xl font-bold text-gray-900">Transactions</h1>
    <div class="flex space-x-3">
        <button onclick="exportTransactions()" class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 flex items-center">
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
            </svg>
            Export
        </button>
    </div>
</div>

<!-- Filters -->
<div class="bg-white rounded-lg shadow p-4 mb-6">
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Date From</label>
            <input type="date" id="dateFrom" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-blue-500 focus:border-blue-500">
        </div>
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Date To</label>
            <input type="date" id="dateTo" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-blue-500 focus:border-blue-500">
        </div>
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Payment Method</label>
            <select id="paymentMethodFilter" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                <option value="">All Methods</option>
                <option value="cash">Cash</option>
                <option value="telebirr">Telebirr</option>
                <option value="cbe_birr">CBE Birr</option>
                <option value="chapa">Chapa</option>
                <option value="card">Card</option>
            </select>
        </div>
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Status</label>
            <select id="statusFilter" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                <option value="">All Status</option>
                <option value="completed">Completed</option>
                <option value="pending">Pending</option>
                <option value="failed">Failed</option>
                <option value="refunded">Refunded</option>
            </select>
        </div>
    </div>
    <div class="mt-4 flex justify-end">
        <button onclick="applyFilters()" class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700">
            Apply Filters
        </button>
    </div>
</div>

<!-- Stats Cards -->
<div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
            <div class="p-3 bg-green-100 rounded-lg">
                <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"></path>
                </svg>
            </div>
            <div class="ml-4">
                <p class="text-sm font-medium text-gray-600">Total Sales</p>
                <p class="text-2xl font-semibold text-gray-900">{{ number_format($totalSales) }} ETB</p>
            </div>
        </div>
    </div>

    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
            <div class="p-3 bg-blue-100 rounded-lg">
                <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
                </svg>
            </div>
            <div class="ml-4">
                <p class="text-sm font-medium text-gray-600">Total Transactions</p>
                <p class="text-2xl font-semibold text-gray-900">{{ $totalTransactions }}</p>
            </div>
        </div>
    </div>

    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
            <div class="p-3 bg-yellow-100 rounded-lg">
                <svg class="w-6 h-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v3m0 0v3m0-3h3m-3 0H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
            </div>
            <div class="ml-4">
                <p class="text-sm font-medium text-gray-600">Average Sale</p>
                <p class="text-2xl font-semibold text-gray-900">{{ number_format($averageSale) }} ETB</p>
            </div>
        </div>
    </div>

    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
            <div class="p-3 bg-purple-100 rounded-lg">
                <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z"></path>
                </svg>
            </div>
            <div class="ml-4">
                <p class="text-sm font-medium text-gray-600">Refunds</p>
                <p class="text-2xl font-semibold text-gray-900">{{ $refundCount }}</p>
            </div>
        </div>
    </div>
</div>

<!-- Transactions Table -->
<div class="bg-white rounded-lg shadow overflow-hidden">
    <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Transaction
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Date & Time
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Customer
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Amount
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Payment Method
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Status
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Actions
                    </th>
                </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
                @foreach($transactions as $transaction)
                    <tr>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <div class="text-sm font-medium text-gray-900">{{ $transaction->transaction_number }}</div>
                            <div class="text-sm text-gray-500">{{ $transaction->items->count() }} items</div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            {{ $transaction->created_at->format('M j, Y') }}<br>
                            <span class="text-gray-400">{{ $transaction->created_at->format('g:i A') }}</span>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            @if($transaction->customer_phone)
                                {{ $transaction->customer_phone }}
                            @else
                                <span class="text-gray-400">Walk-in</span>
                            @endif
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                            {{ number_format($transaction->total_amount) }} ETB
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800 capitalize">
                                {{ $transaction->payment_method }}
                            </span>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full 
                                {{ $transaction->status === 'completed' ? 'bg-green-100 text-green-800' : 
                                   ($transaction->status === 'pending' ? 'bg-yellow-100 text-yellow-800' : 
                                   ($transaction->status === 'refunded' ? 'bg-purple-100 text-purple-800' : 
                                   'bg-red-100 text-red-800')) }}">
                                {{ $transaction->status }}
                            </span>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                            <div class="flex space-x-2">
                                <button onclick="viewTransaction({{ $transaction->id }})" 
                                        class="text-blue-600 hover:text-blue-900 flex items-center">
                                    <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                                    </svg>
                                    View
                                </button>
                                @if($transaction->status === 'completed' && auth()->user()->role !== 'cashier')
                                    <button onclick="refundTransaction({{ $transaction->id }})" 
                                            class="text-purple-600 hover:text-purple-900 flex items-center">
                                        <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                                        </svg>
                                        Refund
                                    </button>
                                @endif
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
                Showing <span>{{ $transactions->firstItem() }}</span> to <span>{{ $transactions->lastItem() }}</span> of <span>{{ $transactions->total() }}</span> results
            </div>
            <div class="flex space-x-2">
                @if($transactions->onFirstPage())
                    <span class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-400 bg-gray-50 cursor-not-allowed">
                        Previous
                    </span>
                @else
                    <a href="{{ $transactions->previousPageUrl() }}" class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50">
                        Previous
                    </a>
                @endif

                @if($transactions->hasMorePages())
                    <a href="{{ $transactions->nextPageUrl() }}" class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50">
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

<!-- Transaction Details Modal -->
<div id="transactionModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full hidden z-50">
    <div class="relative top-20 mx-auto p-5 border w-full max-w-4xl shadow-lg rounded-md bg-white">
        <div class="mt-3">
            <h3 class="text-lg font-medium text-gray-900 mb-4">Transaction Details</h3>
            <div id="transactionDetails">
                <!-- Transaction details will be loaded here -->
            </div>
            <div class="mt-6 flex justify-end">
                <button onclick="closeTransactionModal()" class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 border border-gray-300 rounded-md hover:bg-gray-200">
                    Close
                </button>
            </div>
        </div>
    </div>
</div>

<script>
    function applyFilters() {
        const dateFrom = document.getElementById('dateFrom').value;
        const dateTo = document.getElementById('dateTo').value;
        const paymentMethod = document.getElementById('paymentMethodFilter').value;
        const status = document.getElementById('statusFilter').value;
        
        let url = new URL(window.location.href);
        if (dateFrom) url.searchParams.set('date_from', dateFrom);
        if (dateTo) url.searchParams.set('date_to', dateTo);
        if (paymentMethod) url.searchParams.set('payment_method', paymentMethod);
        if (status) url.searchParams.set('status', status);
        
        window.location.href = url.toString();
    }

    function viewTransaction(transactionId) {
        fetch(`/api/transactions/${transactionId}`)
            .then(response => response.json())
            .then(data => {
                document.getElementById('transactionDetails').innerHTML = `
                    <div class="grid grid-cols-2 gap-4 mb-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-700">Transaction ID</label>
                            <p class="mt-1 text-sm text-gray-900">${data.data.transaction_number}</p>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700">Date & Time</label>
                            <p class="mt-1 text-sm text-gray-900">${new Date(data.data.created_at).toLocaleString()}</p>
                        </div>
                    </div>
                    <div class="grid grid-cols-2 gap-4 mb-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-700">Total Amount</label>
                            <p class="mt-1 text-sm text-gray-900">${parseFloat(data.data.total_amount).toLocaleString()} ETB</p>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700">Payment Method</label>
                            <p class="mt-1 text-sm text-gray-900 capitalize">${data.data.payment_method}</p>
                        </div>
                    </div>
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700">Items</label>
                        <div class="mt-2 border border-gray-200 rounded-md">
                            <table class="min-w-full divide-y divide-gray-200">
                                <thead class="bg-gray-50">
                                    <tr>
                                        <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Product</th>
                                        <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Qty</th>
                                        <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Price</th>
                                        <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Total</th>
                                    </tr>
                                </thead>
                                <tbody class="bg-white divide-y divide-gray-200">
                                    ${data.data.items.map(item => `
                                        <tr>
                                            <td class="px-4 py-2 text-sm text-gray-900">${item.product_name}</td>
                                            <td class="px-4 py-2 text-sm text-gray-500">${item.quantity}</td>
                                            <td class="px-4 py-2 text-sm text-gray-500">${parseFloat(item.unit_price).toLocaleString()} ETB</td>
                                            <td class="px-4 py-2 text-sm text-gray-900">${parseFloat(item.total_price).toLocaleString()} ETB</td>
                                        </tr>
                                    `).join('')}
                                </tbody>
                            </table>
                        </div>
                    </div>
                `;
                document.getElementById('transactionModal').classList.remove('hidden');
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Error loading transaction details');
            });
    }

    function closeTransactionModal() {
        document.getElementById('transactionModal').classList.add('hidden');
    }

    function exportTransactions() {
        alert('Export functionality will be implemented soon!');
    }
</script>
@endsection