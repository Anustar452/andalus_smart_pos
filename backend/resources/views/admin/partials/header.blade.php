{{-- // resources/views/admin/partials/header.blade.php --}}
<nav class="bg-blue-600 text-white shadow-lg">
    <div class="max-w-7xl mx-auto px-4">
        <div class="flex justify-between items-center py-4">
            <div class="flex items-center space-x-4">
                <a href="{{ route('admin.dashboard') }}" class="text-2xl font-bold">Andalus Smart POS</a>
                <span class="bg-blue-500 px-2 py-1 rounded text-sm">Admin</span>
            </div>
            
            <div class="flex items-center space-x-4">
                <a href="{{ route('admin.dashboard') }}" 
                   class="hover:bg-blue-500 px-3 py-2 rounded {{ request()->routeIs('admin.dashboard') ? 'bg-blue-500' : '' }}">
                    Dashboard
                </a>
                <a href="{{ route('admin.products') }}" 
                   class="hover:bg-blue-500 px-3 py-2 rounded {{ request()->routeIs('admin.products') ? 'bg-blue-500' : '' }}">
                    Products
                </a>
                <a href="{{ route('admin.transactions') }}" 
                   class="hover:bg-blue-500 px-3 py-2 rounded {{ request()->routeIs('admin.transactions') ? 'bg-blue-500' : '' }}">
                    Transactions
                </a>
                <a href="{{ route('admin.reports') }}" 
                   class="hover:bg-blue-500 px-3 py-2 rounded {{ request()->routeIs('admin.reports') ? 'bg-blue-500' : '' }}">
                    Reports
                </a>
                <a href="{{ route('admin.users') }}" 
                   class="hover:bg-blue-500 px-3 py-2 rounded {{ request()->routeIs('admin.users') ? 'bg-blue-500' : '' }}">
                    Users
                </a>
                
                <div class="flex items-center space-x-2">
                    <span>{{ auth()->user()->name }}</span>
                    <form action="{{ route('admin.logout') }}" method="POST">
                        @csrf
                        <button type="submit" class="bg-blue-500 hover:bg-blue-700 px-4 py-2 rounded">
                            Logout
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</nav>