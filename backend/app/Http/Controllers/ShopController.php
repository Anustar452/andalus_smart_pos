<?php
// app/Http/Controllers/ShopController.php

namespace App\Http\Controllers;

use App\Models\Shop;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class ShopController extends Controller
{
    public function show(Request $request)
    {
        $shop = $request->user()->shop;
        return response()->json($shop);
    }

    public function update(Request $request)
    {
        $shop = $request->user()->shop;

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'address' => 'required|string|max:500',
            'phone' => 'required|string|max:20',
            'tin_number' => 'nullable|string|max:50',
            'logo' => 'nullable|string',
            'settings.tax_rate' => 'nullable|numeric|min:0|max:100',
            'settings.currency' => 'nullable|string|size:3',
            'settings.receipt_header' => 'nullable|string|max:255',
            'settings.receipt_footer' => 'nullable|string|max:500',
            'settings.print_receipt' => 'boolean',
            'settings.low_stock_threshold' => 'nullable|integer|min:1',
        ]);

        // Handle logo upload
        if ($request->hasFile('logo')) {
            $validated['logo'] = $this->handleLogoUpload($request->file('logo'), $shop);
        }

        $shop->update($validated);

        return response()->json([
            'message' => 'Shop updated successfully',
            'shop' => $shop->fresh()
        ]);
    }

    public function uploadLogo(Request $request)
    {
        $request->validate([
            'logo' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048'
        ]);

        $shop = $request->user()->shop;

        // Delete old logo if exists
        if ($shop->logo && Storage::exists($shop->logo)) {
            Storage::delete($shop->logo);
        }

        $path = $request->file('logo')->store('shop-logos', 'public');
        $shop->update(['logo' => $path]);

        return response()->json([
            'message' => 'Logo uploaded successfully',
            'logo_url' => Storage::url($path)
        ]);
    }

    public function updateSettings(Request $request)
    {
        $shop = $request->user()->shop;

        $validated = $request->validate([
            'tax_rate' => 'nullable|numeric|min:0|max:100',
            'currency' => 'nullable|string|size:3',
            'receipt_header' => 'nullable|string|max:255',
            'receipt_footer' => 'nullable|string|max:500',
            'print_receipt' => 'boolean',
            'low_stock_threshold' => 'nullable|integer|min:1',
            'enable_multiple_cashiers' => 'boolean',
            'require_customer_info' => 'boolean',
            'auto_print_receipt' => 'boolean',
        ]);

        $currentSettings = $shop->settings ?? [];
        $newSettings = array_merge($currentSettings, $validated);

        $shop->update(['settings' => $newSettings]);

        return response()->json([
            'message' => 'Settings updated successfully',
            'settings' => $shop->fresh()->default_settings
        ]);
    }

    private function handleLogoUpload($file, $shop)
    {
        // Delete old logo if exists
        if ($shop->logo && Storage::exists($shop->logo)) {
            Storage::delete($shop->logo);
        }

        return $file->store('shop-logos', 'public');
    }
}