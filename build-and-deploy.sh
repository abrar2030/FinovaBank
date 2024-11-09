# build-and-deploy.sh
# Exit immediately if a command exits with a non-zero status
set -e

echo "Building Maven project..."
cd backend
mvn clean package -DskipTests
cd ..

echo "Building frontend..."
cd frontend/fintech-payment-frontend
npm install
npm run build
cd ../../

echo "Building and deploying services with Docker Compose..."
docker-compose up --build -d

echo "All services are up and running."
