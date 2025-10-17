<?php
// app/Policies/TransactionPolicy.php

namespace App\Policies;

use App\Models\User;
use App\Models\Transaction;
use Illuminate\Auth\Access\HandlesAuthorization;

class TransactionPolicy
{
    use HandlesAuthorization;

    public function view(User $user, Transaction $transaction)
    {
        return $user->shop_id === $transaction->shop_id;
    }

    public function create(User $user)
    {
        return in_array($user->role, ['admin', 'manager', 'cashier']);
    }

    public function refund(User $user, Transaction $transaction)
    {
        return $user->shop_id === $transaction->shop_id && 
               in_array($user->role, ['admin', 'manager']);
    }
}