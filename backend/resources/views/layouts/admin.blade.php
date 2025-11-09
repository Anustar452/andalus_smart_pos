{{-- // resources/views/layouts/admin.blade.php --}}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title') - Andalus POS</title>
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
            @include('admin.partials.sidebar-mobile')
        </div>
    </div>

    <!-- Static sidebar for desktop -->
    <div class="hidden md:flex md:w-64 md:flex-col md:fixed md:inset-y-0">
        @include('admin.partials.sidebar-desktop')
    </div>

    <!-- Main content -->
    <div class="md:pl-64 flex flex-col flex-1">
        <!-- Top navigation -->
        @include('admin.partials.topbar')

        <!-- Page content -->
        <main class="flex-1">
            <div class="py-6">
                <div class="max-w-7xl mx-auto px-4 sm:px-6 md:px-8">
                    @yield('content')
                </div>
            </div>
        </main>
    </div>

    <!-- Scripts -->
    <script>
        // Mobile menu toggle
        function toggleSidebar() {
            return {
                open: false,
                toggle() {
                    this.open = !this.open
                }
            }
        }
    </script>
</body>
</html>