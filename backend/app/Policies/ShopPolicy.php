<?php
// app/Policies/ShopPolicy.php

namespace App\Policies;

use App\Models\User;
use App\Models\Shop;

class ShopPolicy
{
    public function update(User $user, Shop $shop)
    {
        return $user->shop_id === $shop->id && 
               in_array($user->role, ['admin', 'manager']);
    }

    public function updateSettings(User $user, Shop $shop)
    {
        return $user->shop_id === $shop->id && 
               in_array($user->role, ['admin', 'manager']);
    }

    public function uploadLogo(User $user, Shop $shop)
    {
        return $user->shop_id === $shop->id && 
               in_array($user->role, ['admin', 'manager']);
    }
}