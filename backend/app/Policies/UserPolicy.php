<?php
// app/Policies/UserPolicy.php

namespace App\Policies;

use App\Models\User;

class UserPolicy
{
    public function view(User $user, User $model)
    {
        return $user->shop_id === $model->shop_id;
    }

    public function create(User $user)
    {
        return in_array($user->role, ['admin', 'manager']);
    }

    public function update(User $user, User $model)
    {
        return $user->shop_id === $model->shop_id && 
               ($user->role === 'admin' || $user->id === $model->id);
    }

    public function delete(User $user, User $model)
    {
        return $user->shop_id === $model->shop_id && 
               $user->role === 'admin' &&
               $user->id !== $model->id;
    }

    public function updatePassword(User $user, User $model)
    {
        return $user->shop_id === $model->shop_id && 
               ($user->role === 'admin' || $user->id === $model->id);
    }

    public function toggleStatus(User $user, User $model)
    {
        return $user->shop_id === $model->shop_id && 
               $user->role === 'admin' &&
               $user->id !== $model->id;
    }
}