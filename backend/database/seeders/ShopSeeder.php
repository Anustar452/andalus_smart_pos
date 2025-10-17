<?php
// database/seeders/ShopSeeder.php

namespace Database\Seeders;

use App\Models\Shop;
use Illuminate\Database\Seeder;

class ShopSeeder extends Seeder
{
    public function run(): void
    {
        Shop::create([
            'name' => 'Andalus Main Store',
            'address' => 'Addis Ababa, Ethiopia',
            'phone' => '+251911223344',
            'tin_number' => '123456789',
            'settings' => [
                'tax_rate' => 0,
                'currency' => 'ETB',
                'receipt_header' => 'Andalus Main Store',
                'receipt_footer' => 'Thank you for your business!',
                'print_receipt' => true,
                'low_stock_threshold' => 5,
            ],
        ]);
    }
}