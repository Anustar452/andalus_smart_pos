{{-- // resources/views/admin/partials/sidebar-mobile.blade.php --}}
<div class="flex-shrink-0 flex items-center px-4">
    <div class="text-white text-xl font-bold">Andalus POS</div>
</div>
<div class="mt-5 flex-1 h-0 overflow-y-auto">
    <nav class="px-2 space-y-1">
        <!-- Dashboard -->
        <a href="{{ route('admin.dashboard') }}" 
           class="group flex items-center px-2 py-2 text-base font-medium rounded-md 
                  {{ request()->routeIs('admin.dashboard') ? 'bg-blue-900 text-white' : 'text-blue-100 hover:bg-blue-700 hover:text-white' }}">
            <svg class="mr-4 h-6 w-6 {{ request()->routeIs('admin.dashboard') ? 'text-white' : 'text-blue-300' }}" 
                 fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                      d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path>
            </svg>
            Dashboard
        </a>

        <!-- Products -->
        <a href="{{ route('admin.products') }}" 
           class="group flex items-center px-2 py-2 text-base font-medium rounded-md 
                  {{ request()->routeIs('admin.products') ? 'bg-blue-900 text-white' : 'text-blue-100 hover:bg-blue-700 hover:text-white' }}">
            <svg class="mr-4 h-6 w-6 {{ request()->routeIs('admin.products') ? 'text-white' : 'text-blue-300' }}" 
                 fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                      d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"></path>
            </svg>
            Products
        </a>
        {{-- Stock --}}
        <a href="{/admin/stock" 
            class="group flex items-center px-2 py-2 text-sm font-medium rounded-md 
                    {{ request()->routeIs('admin.stock') ? 'bg-blue-900 text-white' : 'text-blue-100 hover:bg-blue-700 hover:text-white' }}">
                <svg class="mr-3 h-6 w-6 {{ request()->routeIs('admin.stock') ? 'text-white' : 'text-blue-300' }}" 
                    fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"></path>
                </svg>
                Stock Management
        </a>
        <!-- Categories -->
        <a href="/admin/categories" 
           class="group flex items-center px-2 py-2 text-base font-medium rounded-md 
                  {{ request()->routeIs('admin.categories') ? 'bg-blue-900 text-white' : 'text-blue-100 hover:bg-blue-700 hover:text-white' }}">
            <svg class="mr-4 h-6 w-6 {{ request()->routeIs('admin.categories') ? 'text-white' : 'text-blue-300' }}" 
                 fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                      d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path>
            </svg>
            Categories
        </a>

        <!-- Transactions -->
        <a href="{{ route('admin.transactions') }}" 
           class="group flex items-center px-2 py-2 text-base font-medium rounded-md 
                  {{ request()->routeIs('admin.transactions') ? 'bg-blue-900 text-white' : 'text-blue-100 hover:bg-blue-700 hover:text-white' }}">
            <svg class="mr-4 h-6 w-6 {{ request()->routeIs('admin.transactions') ? 'text-white' : 'text-blue-300' }}" 
                 fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                      d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
            </svg>
            Transactions
        </a>

        <!-- Reports -->
        <a href="{{ route('admin.reports') }}" 
           class="group flex items-center px-2 py-2 text-base font-medium rounded-md 
                  {{ request()->routeIs('admin.reports') ? 'bg-blue-900 text-white' : 'text-blue-100 hover:bg-blue-700 hover:text-white' }}">
            <svg class="mr-4 h-6 w-6 {{ request()->routeIs('admin.reports') ? 'text-white' : 'text-blue-300' }}" 
                 fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                      d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
            </svg>
            Reports
        </a>

        <!-- Users -->
        <a href="/admin/users" 
           class="group flex items-center px-2 py-2 text-base font-medium rounded-md 
                  {{ request()->routeIs('admin.users') ? 'bg-blue-900 text-white' : 'text-blue-100 hover:bg-blue-700 hover:text-white' }}">
            <svg class="mr-4 h-6 w-6 {{ request()->routeIs('admin.users') ? 'text-white' : 'text-blue-300' }}" 
                 fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                      d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"></path>
            </svg>
            Users
        </a>

        <!-- Settings -->
        <a href="/admin/settings" 
           class="group flex items-center px-2 py-2 text-base font-medium rounded-md 
                  {{ request()->routeIs('admin.settings') ? 'bg-blue-900 text-white' : 'text-blue-100 hover:bg-blue-700 hover:text-white' }}">
            <svg class="mr-4 h-6 w-6 {{ request()->routeIs('admin.settings') ? 'text-white' : 'text-blue-300' }}" 
                 fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                      d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
            </svg>
            Settings
        </a>
    </nav>
</div>