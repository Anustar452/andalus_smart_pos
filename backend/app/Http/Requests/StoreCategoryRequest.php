<?php
// app/Http/Requests/StoreCategoryRequest.php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreCategoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('categories')->where(function ($query) {
                    return $query->where('shop_id', $this->user()->shop_id);
                })
            ],
            'description' => 'nullable|string|max:500',
            'color' => 'nullable|string|max:7|regex:/^#([A-Fa-f0-9]{6})$/',
            'is_active' => 'boolean',
        ];
    }

    public function messages(): array
    {
        return [
            'name.unique' => 'A category with this name already exists in your shop.',
            'color.regex' => 'The color must be a valid hex color code.',
        ];
    }
}