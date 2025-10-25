# FinovaBank Web Frontend

This is the web frontend for the FinovaBank application, a modern and responsive banking application built with React, TypeScript, and Material-UI.

## Features

*   **Dashboard:** View account summaries and recent transactions.
*   **Accounts:** See detailed information about your accounts.
*   **Transactions:** Browse your transaction history.
*   **Loans:** Apply for and manage your loans.
*   **Savings Goals:** Set and track your savings goals.
*   **Authentication:** Secure login and registration functionality.

## Tech Stack

*   **React:** A JavaScript library for building user interfaces.
*   **TypeScript:** A typed superset of JavaScript that compiles to plain JavaScript.
*   **Material-UI (MUI):** A popular React UI framework.
*   **React Router:** For routing and navigation.
*   **Axios:** For making HTTP requests to the backend API.
*   **React Context API:** For state management.

## Getting Started

### Prerequisites

*   Node.js (v14 or later)
*   npm

### Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/abrar2030/FinovaBank.git
    ```
2.  Navigate to the `web-frontend` directory:
    ```bash
    cd FinovaBank/web-frontend
    ```
3.  Install the dependencies:
    ```bash
    npm install
    ```

### Running the Application

1.  Start the development server:
    ```bash
    npm start
    ```
2.  Open your browser and navigate to [http://localhost:3000](http://localhost:3000).

## Available Scripts

*   `npm start`: Runs the app in development mode.
*   `npm test`: Launches the test runner in interactive watch mode.
*   `npm run build`: Builds the app for production.
*   `npm run eject`: Ejects the app from Create React App.

## Project Structure

```
web-frontend/
├── public/           # Public assets
├── src/              # Source code
│   ├── components/   # Reusable components
│   ├── context/      # React context providers
│   ├── pages/        # Page components
│   ├── services/     # API services
│   ├── App.tsx       # Main application component
│   ├── index.tsx     # Entry point of the application
│   └── ...
├── config/           # Configuration files (e.g., theme)
├── package.json      # Project dependencies and scripts
└── README.md         # This file
```

## Enhancements and Refactoring

This project has been refactored and enhanced to improve its structure, maintainability, and security.

*   **Improved Project Structure:** The file structure has been reorganized for better clarity and separation of concerns.
*   **Duplicate Code Removal:** Redundant files and code have been removed to reduce clutter and improve consistency.
*   **Security Enhancement:** The application now uses `sessionStorage` instead of `localStorage` for storing authentication tokens, which is a more secure approach.
*   **Code Refactoring:** The codebase has been refactored to use modern React features and best practices, such as using the `Outlet` component from React Router v6 for layout components.
*   **Updated README:** The README file has been updated to provide more specific and relevant information about the project.

