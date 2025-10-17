<?php
// app/Http/Controllers/AuthController.php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Shop;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\DB;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'shop_name' => 'required|string|max:255',
            'shop_address' => 'required|string|max:500',
            'shop_phone' => 'required|string|max:20',
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'phone' => 'required|string|max:20',
            'password' => 'required|string|min:8|confirmed',
        ]);

        return DB::transaction(function () use ($request) {
            // Create shop
            $shop = Shop::create([
                'name' => $request->shop_name,
                'address' => $request->shop_address,
                'phone' => $request->shop_phone,
                'settings' => [
                    'tax_rate' => 0,
                    'currency' => 'ETB',
                    'receipt_header' => $request->shop_name,
                    'print_receipt' => true,
                ],
            ]);

            // Create admin user
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'phone' => $request->phone,
                'password' => Hash::make($request->password),
                'shop_id' => $shop->id,
                'role' => 'admin',
            ]);

            $token = $user->createToken('andalus-pos')->plainTextToken;

            return response()->json([
                'user' => $user,
                'shop' => $shop,
                'token' => $token,
            ], 201);
        });
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
            'device_name' => 'required',
        ]);

        $user = User::with('shop')->where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        if (!$user->is_active) {
            throw ValidationException::withMessages([
                'email' => ['Your account has been deactivated.'],
            ]);
        }

        if (!$user->shop->is_active) {
            throw ValidationException::withMessages([
                'email' => ['Your shop has been deactivated.'],
            ]);
        }

        $token = $user->createToken($request->device_name)->plainTextToken;

        return response()->json([
            'user' => $user,
            'shop' => $user->shop,
            'token' => $token,
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logged out successfully']);
    }

    public function user(Request $request)
    {
        return response()->json([
            'user' => $request->user()->load('shop'),
            'shop' => $request->user()->shop,
        ]);
    }
}