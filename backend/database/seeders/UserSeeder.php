<?php
// database/seeders/UserSeeder.php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        User::create([
            'name' => 'Admin User',
            'email' => 'admin@andaluspos.com',
            'phone' => '+251911223344',
            'password' => Hash::make('password'),
            'shop_id' => 1,
            'role' => 'admin',
            'is_active' => true,
        ]);

        User::create([
            'name' => 'Manager User',
            'email' => 'manager@andaluspos.com',
            'phone' => '+251922334455',
            'password' => Hash::make('password'),
            'shop_id' => 1,
            'role' => 'manager',
            'is_active' => true,
        ]);

        User::create([
            'name' => 'Cashier User',
            'email' => 'cashier@andaluspos.com',
            'phone' => '+251933445566',
            'password' => Hash::make('password'),
            'shop_id' => 1,
            'role' => 'cashier',
            'is_active' => true,
        ]);
    }
}