{{-- // resources/views/admin/partials/topbar.blade.php --}}
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
                    <h1 class="text-xl font-semibold text-gray-900">@yield('title', 'Dashboard')</h1>
                </div>
            </div>

            <div class="flex items-center">
                <!-- Shop info -->
                <div class="hidden md:flex items-center text-sm text-gray-500 mr-4">
                    <svg class="h-4 w-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                              d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path>
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