# build-and-deploy.sh
# Exit immediately if a command exits with a non-zero status
set -e

echo "Building Maven projects for FinovaBank..."
cd backend
for dir in account-management api-gateway notification transaction user-profile; do
  echo "Building $dir..."
  cd $dir
  mvn clean package -DskipTests
  cd ..
done
cd ..

echo "Building frontend for FinovaBank..."
cd frontend/finovabank-frontend
npm install
npm run build
cd ../../

echo "Building and deploying FinovaBank services with Docker Compose..."
docker-compose up --build -d

echo "All FinovaBank services are up and running."
