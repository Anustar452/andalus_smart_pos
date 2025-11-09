<?php
// app/Exceptions/Handler.php

namespace App\Exceptions;

use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Throwable;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Validation\ValidationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpKernel\Exception\MethodNotAllowedHttpException;
use Illuminate\Http\JsonResponse;

class Handler extends ExceptionHandler
{
    public function render($request, Throwable $exception)
    {
        // Handle API exceptions
        if ($request->expectsJson()) {
            return $this->handleApiException($request, $exception);
        }

        return parent::render($request, $exception);
    }

    private function handleApiException($request, Throwable $exception): JsonResponse
    {
        $statusCode = 500;
        $message = 'Internal Server Error';

        if ($exception instanceof AuthenticationException) {
            $statusCode = 401;
            $message = 'Unauthenticated';
        } elseif ($exception instanceof ValidationException) {
            $statusCode = 422;
            $message = 'Validation Failed';
            $errors = $exception->errors();
        } elseif ($exception instanceof ModelNotFoundException || $exception instanceof NotFoundHttpException) {
            $statusCode = 404;
            $message = 'Resource Not Found';
        } elseif ($exception instanceof MethodNotAllowedHttpException) {
            $statusCode = 405;
            $message = 'Method Not Allowed';
        } elseif (method_exists($exception, 'getStatusCode')) {
            $statusCode = $exception instanceof \Symfony\Component\HttpKernel\Exception\HttpExceptionInterface
                ? $exception->getStatusCode()
                : 500;
            $message = $exception->getMessage() ?: 'Error';
        }

        $response = [
            'success' => false,
            'message' => $message,
            'status' => $statusCode,
        ];

        if (isset($errors)) {
            $response['errors'] = $errors;
        }

        if (config('app.debug')) {
            $response['debug'] = [
                'exception' => get_class($exception),
                'file' => $exception->getFile(),
                'line' => $exception->getLine(),
                'trace' => $exception->getTrace(),
            ];
        }

        return response()->json($response, $statusCode);
    }
}