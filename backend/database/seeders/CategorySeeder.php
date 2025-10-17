<?php
// database/seeders/CategorySeeder.php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            ['name' => 'Electronics', 'color' => '#FF6B6B'],
            ['name' => 'Clothing', 'color' => '#4ECDC4'],
            ['name' => 'Groceries', 'color' => '#45B7D1'],
            ['name' => 'Books', 'color' => '#96CEB4'],
            ['name' => 'Home & Garden', 'color' => '#FFEAA7'],
        ];

        foreach ($categories as $category) {
            Category::create(array_merge($category, [
                'shop_id' => 1,
                'description' => "Products in {$category['name']} category",
            ]));
        }
    }
}