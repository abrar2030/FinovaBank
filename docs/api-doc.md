# FinovaBank API Documentation

## Overview
The FinovaBank platform is a digital banking solution providing various services such as account management, transactions, loan processing, savings goals, risk assessment, compliance, notifications, and reporting. This documentation covers the core REST APIs for each service, their endpoints, expected request and response formats, and status codes.

---

### Base URL
The base URL for all APIs is:
```
http://{host}:{port}/api/v1
```

## API Endpoints

### Account Management Service

#### 1. Create Account
- **Endpoint**: `/accounts`
- **Method**: `POST`
- **Description**: Create a new user account.
- **Request Body**:
  ```json
  {
    "name": "John Doe",
    "email": "john.doe@example.com",
    "phone": "+123456789",
    "accountType": "SAVINGS"
  }
  ```
- **Response**:
  ```json
  {
    "accountId": 1,
    "status": "Account Created"
  }
  ```
- **Status Codes**:
    - `201 Created`
    - `400 Bad Request`

#### 2. Get Account Details
- **Endpoint**: `/accounts/{accountId}`
- **Method**: `GET`
- **Description**: Retrieve details of a specific account.
- **Path Parameters**:
    - `accountId` (Long) - Unique ID of the account.
- **Response**:
  ```json
  {
    "accountId": 1,
    "name": "John Doe",
    "email": "john.doe@example.com",
    "balance": 1000.0,
    "accountType": "SAVINGS"
  }
  ```
- **Status Codes**:
    - `200 OK`
    - `404 Not Found`

---

### Transaction Service

#### 1. Create Transaction
- **Endpoint**: `/transactions`
- **Method**: `POST`
- **Description**: Initiate a fund transfer or other transaction.
- **Request Body**:
  ```json
  {
    "fromAccountId": 1,
    "toAccountId": 2,
    "amount": 500.0,
    "transactionType": "TRANSFER"
  }
  ```
- **Response**:
  ```json
  {
    "transactionId": 101,
    "status": "Transaction Successful"
  }
  ```
- **Status Codes**:
    - `200 OK`
    - `400 Bad Request`

#### 2. Get Transaction Details
- **Endpoint**: `/transactions/{transactionId}`
- **Method**: `GET`
- **Description**: Get details of a specific transaction.
- **Path Parameters**:
    - `transactionId` (Long) - Unique ID of the transaction.
- **Response**:
  ```json
  {
    "transactionId": 101,
    "fromAccountId": 1,
    "toAccountId": 2,
    "amount": 500.0,
    "status": "COMPLETED"
  }
  ```
- **Status Codes**:
    - `200 OK`
    - `404 Not Found`

---

### Loan Management Service

#### 1. Apply for Loan
- **Endpoint**: `/loans`
- **Method**: `POST`
- **Description**: Apply for a loan.
- **Request Body**:
  ```json
  {
    "accountId": 1,
    "loanAmount": 10000.0,
    "loanType": "PERSONAL",
    "durationInMonths": 12
  }
  ```
- **Response**:
  ```json
  {
    "loanId": 1001,
    "status": "Loan Application Submitted"
  }
  ```
- **Status Codes**:
    - `201 Created`
    - `400 Bad Request`

#### 2. Get Loan Details
- **Endpoint**: `/loans/{loanId}`
- **Method**: `GET`
- **Description**: Retrieve details of a loan.
- **Path Parameters**:
    - `loanId` (Long) - Unique ID of the loan.
- **Response**:
  ```json
  {
    "loanId": 1001,
    "accountId": 1,
    "loanAmount": 10000.0,
    "loanType": "PERSONAL",
    "status": "APPROVED"
  }
  ```
- **Status Codes**:
    - `200 OK`
    - `404 Not Found`

---

### Savings Goals Service

#### 1. Create Savings Goal
- **Endpoint**: `/savings`
- **Method**: `POST`
- **Description**: Create a new savings goal.
- **Request Body**:
  ```json
  {
    "accountId": 1,
    "goalName": "Vacation Fund",
    "targetAmount": 5000.0
  }
  ```
- **Response**:
  ```json
  {
    "goalId": 2001,
    "status": "Goal Created"
  }
  ```
- **Status Codes**:
    - `201 Created`
    - `400 Bad Request`

---

## Common Response Status Codes
- `200 OK` - Request processed successfully.
- `201 Created` - Resource created successfully.
- `400 Bad Request` - Invalid request data.
- `404 Not Found` - Resource not found.
- `500 Internal Server Error` - An unexpected error occurred.

## Error Response Format
All error responses will be returned in the following format:
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Detailed error message."
  }
}
```

---

This concludes the API documentation for the FinovaBank services. Feel free to explore further endpoints, or let me know if you need more details.
