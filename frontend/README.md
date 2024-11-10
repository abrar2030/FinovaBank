# FinovaBank - Frontend

This is the frontend of the **FinovaBank** digital banking platform, built using React. It provides users with features like account management, loan details, transaction tracking, savings goals, and notifications.

## Features

- **Account Management**: View account details, balances, and manage account settings.
- **Transactions**: Access transaction history and details.
- **Loans**: Manage loan details and payment schedules.
- **Savings Goals**: Track savings goals and progress.
- **Notifications**: Receive notifications on account activity and updates.

## Technologies

- **Frontend**: React, Axios, CSS
- **API**: Communicates with backend microservices using RESTful APIs
- **Docker**: Containerized deployment using Docker and Nginx

## Getting Started

### Prerequisites

- Node.js and npm
- Docker

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/abrar2030/FinovaBank.git
   cd finovabank-frontend
   ```

2. Install dependencies:

   ```bash
   npm install
   ```

3. Run the frontend application:

   ```bash
   npm start
   ```

### Building the Docker Image

To build the Docker image for the FinovaBank frontend:

1. Make sure Docker is installed and running.

2. Build the Docker image:

   ```bash
   docker build -t finovabank-frontend .
   ```

3. Run the Docker container:

   ```bash
   docker run -p 80:80 finovabank-frontend
   ```

## Environment Variables

Create a `.env` file in the root directory and add the following:

```plaintext
REACT_APP_API_BASE_URL=http://localhost:8080
```

This variable points to the backend API URL.

## License

This project is licensed under the MIT License.

## Contact

For inquiries, please contact [Abrar Ahmed](mailto:abrar@example.com).
