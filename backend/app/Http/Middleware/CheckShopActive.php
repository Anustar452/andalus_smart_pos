<?php
// app/Http/Middleware/CheckShopActive.php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckShopActive
{
    public function handle(Request $request, Closure $next): Response
    {
        $shop = $request->user()->shop;

        if (!$shop->is_active) {
            return response()->json([
                'message' => 'Your shop has been deactivated. Please contact support.'
            ], 403);
        }

        return $next($request);
    }
}