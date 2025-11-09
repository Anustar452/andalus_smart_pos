<?php
// database/seeders/TransactionSeeder.php

namespace Database\Seeders;

use App\Models\Transaction;
use App\Models\TransactionItem;
use App\Models\Product;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class TransactionSeeder extends Seeder
{
    public function run(): void
    {
        $shopId = 1;
        $cashier = User::where('role', 'cashier')->first();
        $products = Product::where('shop_id', $shopId)->get();

        if ($products->isEmpty()) {
            $this->call([ProductSeeder::class]);
            $products = Product::where('shop_id', $shopId)->get();
        }

        $paymentMethods = ['cash', 'telebirr', 'cbe_birr', 'chapa'];

        for ($i = 0; $i < 50; $i++) {
            DB::transaction(function () use ($cashier, $products, $paymentMethods, $shopId) {
                $transaction = Transaction::create([
                    'shop_id' => $shopId,
                    'user_id' => $cashier->id,
                    'transaction_number' => Transaction::generateTransactionNumber($shopId),
                    'total_amount' => 0,
                    'tax_amount' => 0,
                    'discount_amount' => 0,
                    'paid_amount' => 0,
                    'change_amount' => 0,
                    'payment_method' => $paymentMethods[array_rand($paymentMethods)],
                    'status' => 'completed',
                    'customer_phone' => '+2519' . rand(10, 99) . rand(100000, 999999),
                    'created_at' => now()->subDays(rand(0, 30))->subHours(rand(0, 23))->subMinutes(rand(0, 59)),
                ]);

                $totalAmount = 0;
                $itemCount = rand(1, 5);

                for ($j = 0; $j < $itemCount; $j++) {
                    $product = $products->random();
                    $quantity = rand(1, 3);
                    $unitPrice = $product->price;
                    $itemTotal = $quantity * $unitPrice;

                    TransactionItem::create([
                        'transaction_id' => $transaction->id,
                        'product_id' => $product->id,
                        'quantity' => $quantity,
                        'unit_price' => $unitPrice,
                        'total_price' => $itemTotal,
                    ]);

                    $totalAmount += $itemTotal;

                    // Update product stock
                    $product->decrement('stock_quantity', $quantity);
                }

                $paidAmount = $totalAmount;
                if ($transaction->payment_method === 'cash') {
                    // For cash payments, sometimes pay more for change
                    $paidAmount = ceil($totalAmount / 100) * 100;
                }

                $transaction->update([
                    'total_amount' => $totalAmount,
                    'paid_amount' => $paidAmount,
                    'change_amount' => max(0, $paidAmount - $totalAmount),
                ]);
            });
        }
    }
}