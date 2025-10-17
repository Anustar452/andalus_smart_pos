<?php
// app/Policies/ProductPolicy.php

namespace App\Policies;

use App\Models\User;
use App\Models\Product;
use Illuminate\Auth\Access\HandlesAuthorization;

class ProductPolicy
{
    use HandlesAuthorization;

    public function view(User $user, Product $product)
    {
        return $user->shop_id === $product->shop_id;
    }

    public function create(User $user)
    {
        return in_array($user->role, ['admin', 'manager']);
    }

    public function update(User $user, Product $product)
    {
        return $user->shop_id === $product->shop_id && 
               in_array($user->role, ['admin', 'manager']);
    }

    public function delete(User $user, Product $product)
    {
        return $user->shop_id === $product->shop_id && 
               $user->role === 'admin';
    }
}