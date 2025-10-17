// database/migrations/2025_01_01_000005_create_transactions_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('shop_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('transaction_number')->unique();
            $table->decimal('total_amount', 12, 2);
            $table->decimal('tax_amount', 10, 2)->default(0);
            $table->decimal('discount_amount', 10, 2)->default(0);
            $table->decimal('paid_amount', 12, 2);
            $table->decimal('change_amount', 10, 2)->default(0);
            $table->enum('payment_method', ['cash', 'telebirr', 'cbe_birr', 'chapa', 'card']);
            $table->string('payment_reference')->nullable();
            $table->enum('status', ['completed', 'pending', 'failed', 'refunded'])->default('completed');
            $table->boolean('is_online')->default(false);
            $table->string('customer_phone')->nullable();
            $table->string('customer_email')->nullable();
            $table->timestamp('synced_at')->nullable();
            $table->timestamps();
            
            $table->index(['shop_id', 'created_at']);
            $table->index(['shop_id', 'payment_method']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transactions');
    }
};