{{-- resources/views/admin/dashboard.blade.php --}}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Andalus POS - Admin Dashboard</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js" defer></script>
</head>
<body class="bg-gray-100" x-data="{ sidebarOpen: false }">
    <!-- Mobile sidebar backdrop -->
    <div x-show="sidebarOpen" 
         x-transition:enter="transition-opacity ease-linear duration-300"
         x-transition:enter-start="opacity-0"
         x-transition:enter-end="opacity-100"
         x-transition:leave="transition-opacity ease-linear duration-300"
         x-transition:leave-start="opacity-100"
         x-transition:leave-end="opacity-0"
         class="fixed inset-0 flex z-40 md:hidden" 
         style="display: none;">
        <div x-show="sidebarOpen" 
             @click="sidebarOpen = false"
             class="fixed inset-0 bg-gray-600 bg-opacity-75"
             style="display: none;"></div>
    </div>

    <!-- Sidebar for mobile -->
    <div class="md:hidden">
        <div x-show="sidebarOpen"
             x-transition:enter="transition ease-in-out duration-300 transform"
             x-transition:enter-start="-translate-x-full"
             x-transition:enter-end="translate-x-0"
             x-transition:leave="transition ease-in-out duration-300 transform"
             x-transition:leave-start="translate-x-0"
             x-transition:leave-end="-translate-x-full"
             class="fixed inset-y-0 left-0 flex flex-col w-64 bg-blue-800 pt-5 pb-4 z-50"
             style="display: none;">
            <!-- Mobile Sidebar Content -->
            <div class="flex-shrink-0 flex items-center px-4">
                <div class="text-white text-xl font-bold">Andalus POS</div>
            </div>
            <div class="mt-5 flex-1 h-0 overflow-y-auto">
                <nav class="px-2 space-y-1">
                    <a href="/admin/dashboard" 
                       class="group flex items-center px-2 py-2 text-base font-medium rounded-md bg-blue-900 text-white">
                        <svg class="mr-4 h-6 w-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path>
                        </svg>
                        Dashboard
                    </a>

                    <a href="/admin/products" 
                       class="group flex items-center px-2 py-2 text-base font-medium rounded-md text-blue-100 hover:bg-blue-700 hover:text-white">
                        <svg class="mr-4 h-6 w-6 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"></path>
                        </svg>
                        Products
                    </a>

                    <a href="/admin/categories" 
                       class="group flex items-center px-2 py-2 text-base font-medium rounded-md text-blue-100 hover:bg-blue-700 hover:text-white">
                        <svg class="mr-4 h-6 w-6 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path>
                        </svg>
                        Categories
                    </a>

                    <a href="/admin/transactions" 
                       class="group flex items-center px-2 py-2 text-base font-medium rounded-md text-blue-100 hover:bg-blue-700 hover:text-white">
                        <svg class="mr-4 h-6 w-6 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
                        </svg>
                        Transactions
                    </a>

                    <a href="/admin/reports" 
                       class="group flex items-center px-2 py-2 text-base font-medium rounded-md text-blue-100 hover:bg-blue-700 hover:text-white">
                        <svg class="mr-4 h-6 w-6 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                        </svg>
                        Reports
                    </a>

                    <a href="/admin/users" 
                       class="group flex items-center px-2 py-2 text-base font-medium rounded-md text-blue-100 hover:bg-blue-700 hover:text-white">
                        <svg class="mr-4 h-6 w-6 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"></path>
                        </svg>
                        Users
                    </a>

                    <a href="/admin/settings" 
                       class="group flex items-center px-2 py-2 text-base font-medium rounded-md text-blue-100 hover:bg-blue-700 hover:text-white">
                        <svg class="mr-4 h-6 w-6 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                        </svg>
                        Settings
                    </a>
                </nav>
            </div>
        </div>
    </div>

    <!-- Static sidebar for desktop -->
    <div class="hidden md:flex md:w-64 md:flex-col md:fixed md:inset-y-0">
        <div class="flex flex-col flex-grow bg-blue-800 pt-5 overflow-y-auto">
            <!-- Logo -->
            <div class="flex items-center flex-shrink-0 px-4">
                <div class="text-white text-2xl font-bold">Andalus POS</div>
            </div>

            <!-- Navigation -->
            <div class="mt-8 flex-grow flex flex-col">
                <nav class="flex-1 px-2 pb-4 space-y-2">
                    <a href="{{ route('admin.dashboard') }}" 
                       class="group flex items-center px-2 py-2 text-sm font-medium rounded-md bg-blue-900 text-white">
                        <svg class="mr-3 h-6 w-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path>
                        </svg>
                        Dashboard
                    </a>

                    <a href="{{ route('admin.products') }}" 
                       class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-blue-100 hover:bg-blue-700 hover:text-white">
                        <svg class="mr-3 h-6 w-6 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"></path>
                        </svg>
                        Products
                    </a>

                    <a href="/admin/categories" 
                       class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-blue-100 hover:bg-blue-700 hover:text-white">
                        <svg class="mr-3 h-6 w-6 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path>
                        </svg>
                        Categories
                    </a>

                    <a href="{{ route('admin.transactions') }}" 
                       class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-blue-100 hover:bg-blue-700 hover:text-white">
                        <svg class="mr-3 h-6 w-6 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
                        </svg>
                        Transactions
                    </a>

                    <a href="{{ route('admin.reports') }}" 
                       class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-blue-100 hover:bg-blue-700 hover:text-white">
                        <svg class="mr-3 h-6 w-6 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                        </svg>
                        Reports
                    </a>

                    <a href="/admin/users" 
                       class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-blue-100 hover:bg-blue-700 hover:text-white">
                        <svg class="mr-3 h-6 w-6 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"></path>
                        </svg>
                        Users
                    </a>

                    <a href="/admin/settings" 
                       class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-blue-100 hover:bg-blue-700 hover:text-white">
                        <svg class="mr-3 h-6 w-6 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                        </svg>
                        Settings
                    </a>
                </nav>
            </div>

            <!-- User section -->
            <div class="flex-shrink-0 flex border-t border-blue-700 p-4">
                <div class="flex items-center w-full">
                    <div class="flex-shrink-0">
                        <div class="h-8 w-8 rounded-full bg-blue-600 flex items-center justify-center text-white font-bold">
                            {{ strtoupper(substr(auth()->user()->name, 0, 1)) }}
                        </div>
                    </div>
                    <div class="ml-3 flex-1">
                        <p class="text-sm font-medium text-white">{{ auth()->user()->name }}</p>
                        <p class="text-xs font-medium text-blue-300">{{ auth()->user()->role }}</p>
                    </div>
                    <div class="ml-3">
                        <form action="{{ route('admin.logout') }}" method="POST">
                            @csrf
                            <button type="submit" class="text-blue-300 hover:text-white">
                                <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
                                </svg>
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Main content -->
    <div class="md:pl-64 flex flex-col flex-1">
        <!-- Top navigation -->
        <nav class="bg-white shadow-sm border-b border-gray-200">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div class="flex justify-between h-16">
                    <div class="flex">
                        <!-- Mobile menu button -->
                        <div class="md:hidden flex items-center">
                            <button @click="sidebarOpen = true" 
                                    class="inline-flex items-center justify-center p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-blue-500">
                                <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
                                </svg>
                            </button>
                        </div>

                        <!-- Page title -->
                        <div class="flex-shrink-0 flex items-center">
                            <h1 class="text-xl font-semibold text-gray-900">Dashboard</h1>
                        </div>
                    </div>

                    <div class="flex items-center">
                        <!-- Shop info -->
                        <div class="hidden md:flex items-center text-sm text-gray-500 mr-4">
                            <svg class="h-4 w-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path>
                            </svg>
                            {{ auth()->user()->shop->name }}
                        </div>

                        <!-- User dropdown -->
                        <div class="ml-3 relative">
                            <div class="flex items-center space-x-3">
                                <div class="text-sm text-gray-700">
                                    <div class="font-medium">{{ auth()->user()->name }}</div>
                                    <div class="text-gray-500 capitalize">{{ auth()->user()->role }}</div>
                                </div>
                                <div class="flex-shrink-0">
                                    <div class="h-8 w-8 rounded-full bg-blue-600 flex items-center justify-center text-white font-bold">
                                        {{ strtoupper(substr(auth()->user()->name, 0, 1)) }}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </nav>

        <!-- Page content -->
        <main class="flex-1">
            <div class="py-6">
                <div class="max-w-7xl mx-auto px-4 sm:px-6 md:px-8">
                    <!-- Stats Cards -->
                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                        <div class="bg-white rounded-lg shadow p-6">
                            <div class="flex items-center">
                                <div class="p-3 bg-green-100 rounded-lg">
                                    <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"></path>
                                    </svg>
                                </div>
                                <div class="ml-4">
                                    <p class="text-sm font-medium text-gray-600">Today's Sales</p>
                                    <p class="text-2xl font-semibold text-gray-900">
                                        {{ number_format($todaySales->total_sales ?? 0) }} ETB
                                    </p>
                                </div>
                            </div>
                        </div>

                        <div class="bg-white rounded-lg shadow p-6">
                            <div class="flex items-center">
                                <div class="p-3 bg-blue-100 rounded-lg">
                                    <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"></path>
                                    </svg>
                                </div>
                                <div class="ml-4">
                                    <p class="text-sm font-medium text-gray-600">Total Products</p>
                                    <p class="text-2xl font-semibold text-gray-900">{{ $totalProducts ?? 0 }}</p>
                                </div>
                            </div>
                        </div>

                        <div class="bg-white rounded-lg shadow p-6">
                            <div class="flex items-center">
                                <div class="p-3 bg-yellow-100 rounded-lg">
                                    <svg class="w-6 h-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.35 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
                                    </svg>
                                </div>
                                <div class="ml-4">
                                    <p class="text-sm font-medium text-gray-600">Low Stock Items</p>
                                    <p class="text-2xl font-semibold text-gray-900">{{ $lowStockProducts ?? 0 }}</p>
                                </div>
                            </div>
                        </div>

                        <div class="bg-white rounded-lg shadow p-6">
                            <div class="flex items-center">
                                <div class="p-3 bg-purple-100 rounded-lg">
                                    <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
                                    </svg>
                                </div>
                                <div class="ml-4">
                                    <p class="text-sm font-medium text-gray-600">Today's Transactions</p>
                                    <p class="text-2xl font-semibold text-gray-900">{{ $todaySales->transaction_count ?? 0 }}</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Charts Section -->
                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
                        <div class="bg-white rounded-lg shadow p-6">
                            <h3 class="text-lg font-semibold mb-4">Sales Trend (Last 7 Days)</h3>
                            <canvas id="salesChart" height="250"></canvas>
                        </div>
                        
                        <div class="bg-white rounded-lg shadow p-6">
                            <h3 class="text-lg font-semibold mb-4">Payment Methods</h3>
                            <canvas id="paymentChart" height="250"></canvas>
                        </div>
                    </div>

                    <!-- Recent Transactions & Top Products -->
                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
                        <!-- Recent Transactions -->
                        <div class="bg-white rounded-lg shadow">
                            <div class="px-6 py-4 border-b border-gray-200">
                                <h3 class="text-lg font-semibold">Recent Transactions</h3>
                            </div>
                            <div class="p-6">
                                <div class="overflow-x-auto">
                                    <table class="min-w-full divide-y divide-gray-200">
                                        <thead class="bg-gray-50">
                                            <tr>
                                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                                    Transaction ID
                                                </th>
                                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                                    Amount
                                                </th>
                                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                                    Status
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody class="bg-white divide-y divide-gray-200">
                                            @php
                                                $recentTransactions = \App\Models\Transaction::with('user')
                                                    ->where('shop_id', auth()->user()->shop_id)
                                                    ->orderBy('created_at', 'desc')
                                                    ->limit(5)
                                                    ->get();
                                            @endphp
                                            
                                            @forelse($recentTransactions as $transaction)
                                                <tr>
                                                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                                                        {{ $transaction->transaction_number }}
                                                    </td>
                                                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                                        {{ number_format($transaction->total_amount) }} ETB
                                                    </td>
                                                    <td class="px-6 py-4 whitespace-nowrap">
                                                        <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full 
                                                            {{ $transaction->status === 'completed' ? 'bg-green-100 text-green-800' : 
                                                               ($transaction->status === 'pending' ? 'bg-yellow-100 text-yellow-800' : 
                                                               'bg-red-100 text-red-800') }}">
                                                            {{ $transaction->status }}
                                                        </span>
                                                    </td>
                                                </tr>
                                            @empty
                                                <tr>
                                                    <td colspan="3" class="px-6 py-4 text-center text-gray-500">
                                                        No transactions found
                                                    </td>
                                                </tr>
                                            @endforelse
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>

                        <!-- Top Products -->
                        <div class="bg-white rounded-lg shadow">
                            <div class="px-6 py-4 border-b border-gray-200">
                                <h3 class="text-lg font-semibold">Top Selling Products</h3>
                            </div>
                            <div class="p-6">
                                <div class="space-y-4">
                                    @php
                                        $topProducts = \App\Models\Product::where('shop_id', auth()->user()->shop_id)
                                            ->orderBy('stock_quantity', 'asc')
                                            ->limit(5)
                                            ->get();
                                    @endphp
                                    
                                    @forelse($topProducts as $product)
                                        <div class="flex items-center justify-between">
                                            <div class="flex items-center">
                                                <div class="ml-4">
                                                    <p class="text-sm font-medium text-gray-900">{{ $product->name }}</p>
                                                    <p class="text-sm text-gray-500">Stock: {{ $product->stock_quantity }}</p>
                                                </div>
                                            </div>
                                            <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full 
                                                {{ $product->stock_quantity <= $product->min_stock ? 'bg-red-100 text-red-800' : 'bg-green-100 text-green-800' }}">
                                                {{ $product->stock_quantity <= $product->min_stock ? 'Low Stock' : 'In Stock' }}
                                            </span>
                                        </div>
                                    @empty
                                        <p class="text-center text-gray-500">No products found</p>
                                    @endforelse
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        // Initialize charts
        document.addEventListener('DOMContentLoaded', function() {
            // Sales Chart
            const salesCtx = document.getElementById('salesChart').getContext('2d');
            new Chart(salesCtx, {
                type: 'line',
                data: {
                    labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                    datasets: [{
                        label: 'Sales (ETB)',
                        data: [12000, 19000, 15000, 25000, 22000, 30000, 28000],
                        borderColor: '#3B82F6',
                        backgroundColor: 'rgba(59, 130, 246, 0.1)',
                        tension: 0.4
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            display: false
                        }
                    }
                }
            });

            // Payment Methods Chart
            const paymentCtx = document.getElementById('paymentChart').getContext('2d');
            new Chart(paymentCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Cash', 'Telebirr', 'CBE Birr', 'Chapa'],
                    datasets: [{
                        data: [40, 30, 20, 10],
                        backgroundColor: [
                            '#10B981',
                            '#3B82F6',
                            '#F59E0B',
                            '#8B5CF6'
                        ]
                    }]
                }
            });
        });
    </script>
</body>
</html>