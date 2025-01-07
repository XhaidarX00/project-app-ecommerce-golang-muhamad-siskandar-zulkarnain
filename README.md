# E-Commerce API Documentation

## Table of Contents
- [Overview](#overview)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Authentication](#authentication)
- [API Endpoints](#api-endpoints)
- [Response Format](#response-format)
- [Error Handling](#error-handling)
- [Middleware](#middleware)
- [Database](#database)
- [Validation](#validation)
- [Logging](#logging)

## Overview

This is a RESTful API for an e-commerce platform built with Go. The API provides endpoints for user authentication, product management, shopping cart operations, and order processing.

## Project Structure

```
├── asset/
├── database/
├── handler/
├── helper/
├── middleware/
├── model/
├── repository/
├── responsejson/
├── router/
├── service/
├── util/
├── .env
├── .env.sampel
├── app.log
├── db.sql
├── go.mod
├── go.sum
└── main.go
```

## Configuration

### Environment Variables
The application uses a `.env` file for configuration. Required variables:

```env
APP_NAME=
PORT=
DEBUG=
DATABASE_NAME=
DATABASE_USERNAME=
DATABASE_PASSWORD=
DATABASE_HOST=
DIR_UPLOAD=
```

### Configuration Structure
```go
type Configuration struct {
    AppName   string
    Port      string
    Debug     bool
    DB        DatabaseConfig
    DirUpload string
}

type DatabaseConfig struct {
    Name     string
    Username string
    Password string
    Host     string
}
```

## Authentication

### Register
**Endpoint:** `POST /register`

**Response Success (201):**
```json
{
    "Status": 201,
    "Message": "succes register",
    "Data": {
        "id": 16,
        "name": "Haidar2",
        "phone_number": "0877742476333",
        "password": "pass123",
        "token": "523db5eb-2b8c-4e5e-8d83-4c595a608199",
        "created_at": "0001-01-01T00:00:00Z",
        "update_at": "0001-01-01T00:00:00Z"
    }
}
```

### Login
**Endpoint:** `POST /login`

**Response Success (200):**
```json
{
    "Status": 200,
    "Message": "Succes Login",
    "Data": {
        "id": 1,
        "name": "Iskandar",
        "email": "iskandar@example.com",
        "password": "pass123",
        "token": "token_admin_1",
        "created_at": "0001-01-01T00:00:00Z",
        "update_at": "0001-01-01T00:00:00Z"
    }
}
```

## API Endpoints

All protected endpoints require token authentication in the header: `token: <token_value>`

### Product Endpoints
- `GET /api/banner` - Get banner data
- `GET /api/categories` - Get product categories
- `GET /api/best-selling` - Get best-selling products
- `GET /api/promo-weekly` - Get weekly promotions
- `GET /api/list-product` - Get all products
- `GET /api/list-recomment` - Get recommended products
- `GET /api/page-products` - Get paginated products
- `GET /api/product-detail` - Get product details

### Cart Endpoints
- `GET /api/list-cart` - Get cart items
- `POST /api/add-to-cart` - Add item to cart
- `POST /api/update-cart-items` - Update cart items
- `DELETE /api/delete-cart-items` - Remove items from cart

### Order Endpoints
- `GET /api/customer-address` - Get customer addresses
- `POST /api/add-order` - Create new order

## Response Format

### Standard Response
```go
type Response struct {
    Status  int
    Message string
    Data    interface{}
}
```

### Pagination Response
```json
{
    "status_code": 200,
    "message": "succes get data allProduct",
    "page": 1,
    "limit": 8,
    "total_items": 10,
    "total_pages": 2,
    "data": [...]
}
```

## Error Handling

### Common Error Responses

- **Not Found (404)**
```json
{
    "Status": 404,
    "Message": "data tidak ditemukan",
    "Data": null
}
```

- **Unauthorized (401)**
```json
{
    "Status": 401,
    "Message": "email atau phone number tidak valid, atau password salah",
    "Data": null
}
```

- **Unprocessable Entity (422)**
```json
{
    "Status": 422,
    "Message": "inputan tidak valid",
    "Data": null
}
```

## Middleware

### Logger Middleware
Logs HTTP requests with:
- URL
- Duration
- Timestamp

### Token Middleware
Validates authentication token for protected endpoints:
- Checks token presence in header
- Validates token against service
- Returns 401 if token is invalid

## Database

### Connection Configuration
```go
type DatabaseConfig struct {
    Name     string
    Username string
    Password string
    Host     string
}
```

### Connection Settings
- Max Open Connections: 25
- Max Idle Connections: 25
- Connection Max Lifetime: 30 minutes
- Connection Max Idle Time: 5 minutes

## Validation

Uses `go-playground/validator/v10` for input validation with custom error messages.

### Validation Example
```go
type FieldError struct {
    Field   string `json:"field"`
    Message string `json:"message"`
}
```

### Common Validation Rules
- Required fields
- Email format
- Minimum length
- Field equality
- Non-negative numbers

## Logging

Uses `uber-go/zap` for structured logging:
- Log Level: Info
- Format: JSON
- File: app.log

### Log Entry Example
```json
{
    "L": "INFO",
    "T": "2024-11-23T21:26:54.305+0700",
    "M": "server started on http://localhost:8080"
}
```
