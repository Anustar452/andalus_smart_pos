<?php
// app/Http/Controllers/Admin/UserController.php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function index()
    {
        $users = User::where('shop_id', auth()->guard()->user()->shop_id)
            ->orderBy('name')
            ->get();

        return view('admin.users.index', compact('users'));
    }
}