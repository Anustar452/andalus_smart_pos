{{-- resources/views/admin/reports/index.blade.php --}}
@extends('layouts.admin')

@section('title', 'Reports & Analytics')

@section('content')
<div class="flex justify-between items-center mb-6">
    <h1 class="text-2xl font-bold text-gray-900">Reports & Analytics</h1>
    <div class="flex space-x-3">
        <select id="reportPeriod" class="border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-blue-500 focus:border-blue-500">
            <option value="today">Today</option>
            <option value="yesterday">Yesterday</option>
            <option value="week" selected>This Week</option>
            <option value="month">This Month</option>
            <option value="year">This Year</option>
            <option value="custom">Custom Range</option>
        </select>
        <button onclick="exportReport()" class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 flex items-center">
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
            </svg>
            Export Report
        </button>
    </div>
</div>

<!-- Custom Date Range (hidden by default) -->
<div id="customDateRange" class="bg-white rounded-lg shadow p-4 mb-6 hidden">
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
            <label class="block text-sm font-medium text-gray-700">Start Date</label>
            <input type="date" id="startDate" class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500">
        </div>
        <div>
            <label class="block text-sm font-medium text-gray-700">End Date</label>
            <input type="date" id="endDate" class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500">
        </div>
        <div class="flex items-end">
            <button onclick="applyCustomDateRange()" class="w-full bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700">
                Apply
            </button>
        </div>
    </div>
</div>

<!-- Key Metrics -->
<div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
            <div class="p-3 bg-green-100 rounded-lg">
                <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"></path>
                </svg>
            </div>
            <div class="ml-4">
                <p class="text-sm font-medium text-gray-600">Total Revenue</p>
                <p class="text-2xl font-semibold text-gray-900">{{ number_format($salesSummary->total_sales ?? 0) }} ETB</p>
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
                <p class="text-sm font-medium text-gray-600">Transactions</p>
                <p class="text-2xl font-semibold text-gray-900">{{ $salesSummary->total_transactions ?? 0 }}</p>
            </div>
        </div>
    </div>

    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
            <div class="p-3 bg-yellow-100 rounded-lg">
                <svg class="w-6 h-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"></path>
                </svg>
            </div>
            <div class="ml-4">
                <p class="text-sm font-medium text-gray-600">Average Sale</p>
                <p class="text-2xl font-semibold text-gray-900">{{ number_format($salesSummary->average_sale ?? 0) }} ETB</p>
            </div>
        </div>
    </div>

    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
            <div class="p-3 bg-purple-100 rounded-lg">
                <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                </svg>
            </div>
            <div class="ml-4">
                <p class="text-sm font-medium text-gray-600">Products Sold</p>
                <p class="text-2xl font-semibold text-gray-900">{{ $totalProductsSold ?? 0 }}</p>
            </div>
        </div>
    </div>
</div>

<!-- Charts Section -->
<div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
    <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-lg font-semibold mb-4">Sales Trend</h3>
        <canvas id="salesTrendChart" height="250"></canvas>
    </div>
    
    <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-lg font-semibold mb-4">Payment Methods Distribution</h3>
        <canvas id="paymentMethodsChart" height="250"></canvas>
    </div>
</div>

<!-- Top Products & Categories -->
<div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
    <!-- Top Selling Products -->
    <div class="bg-white rounded-lg shadow">
        <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-semibold">Top Selling Products</h3>
        </div>
        <div class="p-6">
            <div class="space-y-4">
                @foreach($topProducts as $product)
                    <div class="flex items-center justify-between">
                        <div class="flex items-center">
                            <div class="ml-4">
                                <p class="text-sm font-medium text-gray-900">{{ $product->name }}</p>
                                <p class="text-sm text-gray-500">{{ $product->total_quantity }} sold</p>
                            </div>
                        </div>
                        <div class="text-right">
                            <p class="text-sm font-medium text-gray-900">{{ number_format($product->total_revenue) }} ETB</p>
                            <p class="text-sm text-gray-500">{{ number_format($product->total_quantity * $product->average_price) }} ETB</p>
                        </div>
                    </div>
                @endforeach
            </div>
        </div>
    </div>

    <!-- Sales by Category -->
    <div class="bg-white rounded-lg shadow">
        <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-semibold">Sales by Category</h3>
        </div>
        <div class="p-6">
            <div class="space-y-4">
                @foreach($categorySales as $category)
                    <div class="flex items-center justify-between">
                        <div class="flex items-center">
                            <div class="w-3 h-3 rounded-full mr-3" style="background-color: {{ $category->color }}"></div>
                            <span class="text-sm font-medium text-gray-900">{{ $category->name }}</span>
                        </div>
                        <div class="text-right">
                            <p class="text-sm font-medium text-gray-900">{{ number_format($category->total_revenue) }} ETB</p>
                            <p class="text-sm text-gray-500">{{ $category->total_quantity }} items</p>
                        </div>
                    </div>
                @endforeach
            </div>
        </div>
    </div>
</div>

<!-- Detailed Reports Table -->
<div class="bg-white rounded-lg shadow">
    <div class="px-6 py-4 border-b border-gray-200">
        <h3 class="text-lg font-semibold">Detailed Sales Report</h3>
    </div>
    <div class="p-6">
        <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Date
                        </th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Transactions
                        </th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Total Sales
                        </th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Average Sale
                        </th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Products Sold
                        </th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                    @foreach($dailySales as $sale)
                        <tr>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                {{ \Carbon\Carbon::parse($sale->date)->format('M j, Y') }}
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                {{ $sale->transaction_count }}
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                {{ number_format($sale->total_sales) }} ETB
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                {{ number_format($sale->average_sale) }} ETB
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                {{ $sale->products_sold }}
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
    document.getElementById('reportPeriod').addEventListener('change', function(e) {
        if (e.target.value === 'custom') {
            document.getElementById('customDateRange').classList.remove('hidden');
        } else {
            document.getElementById('customDateRange').classList.add('hidden');
            loadReportData(e.target.value);
        }
    });

    function applyCustomDateRange() {
        const startDate = document.getElementById('startDate').value;
        const endDate = document.getElementById('endDate').value;
        
        if (startDate && endDate) {
            loadReportData('custom', startDate, endDate);
        } else {
            alert('Please select both start and end dates');
        }
    }

    function loadReportData(period, startDate = null, endDate = null) {
        // Implement AJAX call to load report data based on period
        console.log('Loading report for:', period, startDate, endDate);
        // This would make an API call to fetch new data and update charts
    }

    function exportReport() {
        alert('Export functionality will be implemented soon!');
    }

    // Initialize charts
    document.addEventListener('DOMContentLoaded', function() {
        // Sales Trend Chart
        const salesTrendCtx = document.getElementById('salesTrendChart').getContext('2d');
        new Chart(salesTrendCtx, {
            type: 'line',
            data: {
                labels: {!! json_encode($salesTrend->pluck('date')) !!},
                datasets: [{
                    label: 'Sales (ETB)',
                    data: {!! json_encode($salesTrend->pluck('total_sales')) !!},
                    borderColor: '#3B82F6',
                    backgroundColor: 'rgba(59, 130, 246, 0.1)',
                    tension: 0.4,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                return value.toLocaleString() + ' ETB';
                            }
                        }
                    }
                }
            }
        });

        // Payment Methods Chart
        const paymentMethodsCtx = document.getElementById('paymentMethodsChart').getContext('2d');
        new Chart(paymentMethodsCtx, {
            type: 'doughnut',
            data: {
                labels: {!! json_encode($paymentMethods->pluck('payment_method')) !!},
                datasets: [{
                    data: {!! json_encode($paymentMethods->pluck('total_amount')) !!},
                    backgroundColor: [
                        '#10B981', // Cash - Green
                        '#3B82F6', // Telebirr - Blue
                        '#F59E0B', // CBE Birr - Yellow
                        '#8B5CF6', // Chapa - Purple
                        '#EF4444'  // Card - Red
                    ]
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom'
                    }
                }
            }
        });
    });
</script>
@endsection