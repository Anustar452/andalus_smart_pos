<?php
// database/seeders/ProductSeeder.php

namespace Database\Seeders;

use App\Models\Product;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $products = [
            [
                'name' => 'Smartphone X',
                'barcode' => '1234567890123',
                'description' => 'Latest smartphone with advanced features',
                'price' => 15000.00,
                'cost_price' => 12000.00,
                'stock_quantity' => 50,
                'min_stock' => 5,
                'category_id' => 1,
            ],
            [
                'name' => 'Laptop Pro',
                'barcode' => '1234567890124',
                'description' => 'High-performance laptop for professionals',
                'price' => 45000.00,
                'cost_price' => 38000.00,
                'stock_quantity' => 20,
                'min_stock' => 3,
                'category_id' => 1,
            ],
            [
                'name' => 'T-Shirt Cotton',
                'barcode' => '1234567890125',
                'description' => 'Comfortable cotton t-shirt',
                'price' => 350.00,
                'cost_price' => 250.00,
                'stock_quantity' => 100,
                'min_stock' => 10,
                'category_id' => 2,
            ],
            [
                'name' => 'Coffee Beans',
                'barcode' => '1234567890126',
                'description' => 'Premium Ethiopian coffee beans',
                'price' => 450.00,
                'cost_price' => 300.00,
                'stock_quantity' => 75,
                'min_stock' => 15,
                'category_id' => 3,
            ],
            [
                'name' => 'Programming Book',
                'barcode' => '1234567890127',
                'description' => 'Learn programming with this comprehensive guide',
                'price' => 850.00,
                'cost_price' => 600.00,
                'stock_quantity' => 30,
                'min_stock' => 5,
                'category_id' => 4,
            ],
        ];

        foreach ($products as $product) {
            Product::create(array_merge($product, [
                'shop_id' => 1,
                'is_active' => true,
            ]));
        }
    }
}