<?php
// app/Http/Controllers/UserController.php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;

class UserController extends Controller
{
    use AuthorizesRequests;
    public function index(Request $request)
    {
        $users = User::where('shop_id', $request->user()->shop_id)
            ->orderBy('name')
            ->get();

        return response()->json($users);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => [
                'required',
                'string',
                'email',
                'max:255',
                Rule::unique('users')->where(function ($query) use ($request) {
                    return $query->where('shop_id', $request->user()->shop_id);
                })
            ],
            'phone' => 'required|string|max:20',
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
            'role' => 'required|in:admin,manager,cashier',
        ]);

        $validated['shop_id'] = $request->user()->shop_id;
        $validated['password'] = Hash::make($validated['password']);

        $user = User::create($validated);

        return response()->json($user, 201);
    }

    public function show(User $user)
    {
        $this->authorize('view', $user);
        return response()->json($user);
    }

    public function update(Request $request, User $user)
    {
        $this->authorize('update', $user);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => [
                'required',
                'string',
                'email',
                'max:255',
                Rule::unique('users')->where(function ($query) use ($request, $user) {
                    return $query->where('shop_id', $request->user()->shop_id)
                                ->where('id', '!=', $user->id);
                })
            ],
            'phone' => 'required|string|max:20',
            'role' => 'required|in:admin,manager,cashier',
            'is_active' => 'boolean',
        ]);

        $user->update($validated);

        return response()->json($user);
    }

    public function updatePassword(Request $request, User $user)
    {
        $this->authorize('update', $user);

        $validated = $request->validate([
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
        ]);

        $user->update([
            'password' => Hash::make($validated['password']),
        ]);

        return response()->json(['message' => 'Password updated successfully']);
    }

    public function toggleStatus(User $user)
    {
        $this->authorize('update', $user);

        $user->update([
            'is_active' => !$user->is_active,
        ]);

        $status = $user->is_active ? 'activated' : 'deactivated';

        return response()->json([
            'message' => "User {$status} successfully",
            'user' => $user
        ]);
    }

    public function destroy(User $user)
    {
        $this->authorize('delete', $user);

        // Prevent deleting own account
        if ($user->id === optional(auth()->guard()->user())->id) {
            return response()->json([
                'message' => 'You cannot delete your own account.'
            ], 422);
        }

        $user->delete();

        return response()->json(['message' => 'User deleted successfully']);
    }
}