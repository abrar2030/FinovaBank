#!/bin/bash
# =====================================================
# FinovaBank Testing Automation Script
# =====================================================
# This script automates the testing process for all components
# of the FinovaBank platform, including unit tests, integration
# tests, and end-to-end tests.
#
# Author: Manus AI
# Date: May 22, 2025
# =====================================================

set -e

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
TEST_REPORT_DIR="./test-reports"
COVERAGE_REPORT_DIR="./coverage-reports"
TEST_TIMEOUT=300 # 5 minutes

# Function to display usage information
usage() {
    echo -e "${BLUE}Usage:${NC} $0 [options] [components]"
    echo -e ""
    echo -e "${BLUE}Components:${NC}"
    echo -e "  all                  Test all components (default)"
    echo -e "  backend              Test backend services only"
    echo -e "  frontend             Test web frontend only"
    echo -e "  mobile               Test mobile frontend only"
    echo -e "  ai                   Test AI services only"
    echo -e ""
    echo -e "${BLUE}Options:${NC}"
    echo -e "  --help               Display this help message"
    echo -e "  --unit               Run unit tests only"
    echo -e "  --integration        Run integration tests only"
    echo -e "  --e2e                Run end-to-end tests only"
    echo -e "  --coverage           Generate coverage reports"
    echo -e "  --report-dir DIR     Test report directory (default: $TEST_REPORT_DIR)"
    echo -e "  --coverage-dir DIR   Coverage report directory (default: $COVERAGE_REPORT_DIR)"
    echo -e "  --timeout SECONDS    Test timeout in seconds (default: $TEST_TIMEOUT)"
    echo -e "  --ci                 Run in CI mode (non-interactive)"
    echo -e ""
    exit 0
}

# Function to display a step message
step_msg() {
    echo -e "\n${BLUE}==>${NC} ${GREEN}$1${NC}"
}

# Function to display an error message
error_msg() {
    echo -e "\n${RED}ERROR:${NC} $1"
    exit 1
}

# Function to display a warning message
warning_msg() {
    echo -e "\n${YELLOW}WARNING:${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to run backend tests
run_backend_tests() {
    step_msg "Running backend tests..."

    if [ ! -d "backend" ]; then
        error_msg "Backend directory not found"
    fi

    cd backend

    # Create report directories
    mkdir -p "../$TEST_REPORT_DIR/backend"

    # Determine test types to run
    local test_types=""
    if [ "$RUN_UNIT" = true ]; then
        test_types="$test_types test"
    fi
    if [ "$RUN_INTEGRATION" = true ]; then
        test_types="$test_types integration-test"
    fi

    # If no specific test type is selected, run all tests
    if [ -z "$test_types" ]; then
        test_types="test integration-test"
    fi

    # Run tests with Maven
    for test_type in $test_types; do
        echo "Running backend $test_type..."

        # Add coverage if requested
        local coverage_opts=""
        if [ "$GENERATE_COVERAGE" = true ]; then
            coverage_opts="-Djacoco.destFile=../coverage-reports/backend/jacoco.exec"
            mkdir -p "../$COVERAGE_REPORT_DIR/backend"
        fi

        # Run the tests
        ./mvnw $test_type $coverage_opts -Dmaven.test.failure.ignore=false

        # Check exit code
        if [ $? -ne 0 ]; then
            cd ..
            error_msg "Backend $test_type failed"
        fi
    done

    # Generate coverage report if requested
    if [ "$GENERATE_COVERAGE" = true ]; then
        echo "Generating backend coverage report..."
        ./mvnw jacoco:report -Djacoco.dataFile=../coverage-reports/backend/jacoco.exec -Djacoco.outputDirectory=../coverage-reports/backend
    fi

    cd ..

    echo -e "${GREEN}Backend tests completed successfully!${NC}"
}

# Function to run web frontend tests
run_frontend_tests() {
    step_msg "Running web frontend tests..."

    if [ ! -d "web-frontend" ]; then
        error_msg "Web frontend directory not found"
    fi

    cd web-frontend

    # Create report directories
    mkdir -p "../$TEST_REPORT_DIR/web-frontend"

    # Install dependencies if node_modules doesn't exist
    if [ ! -d "node_modules" ]; then
        echo "Installing dependencies..."
        npm install
    fi

    # Determine test types to run
    if [ "$RUN_UNIT" = true ]; then
        echo "Running frontend unit tests..."

        # Add coverage if requested
        local coverage_opts=""
        if [ "$GENERATE_COVERAGE" = true ]; then
            coverage_opts="--coverage --coverageDirectory=../$COVERAGE_REPORT_DIR/web-frontend"
            mkdir -p "../$COVERAGE_REPORT_DIR/web-frontend"
        fi

        # Run unit tests
        npm test -- --watchAll=false $coverage_opts --testResultsProcessor=jest-junit --reporters=default --reporters=jest-junit

        # Check exit code
        if [ $? -ne 0 ]; then
            cd ..
            error_msg "Frontend unit tests failed"
        fi
    fi

    # Run E2E tests if requested
    if [ "$RUN_E2E" = true ]; then
        echo "Running frontend end-to-end tests..."

        # Check if Cypress is installed
        if [ ! -d "node_modules/cypress" ]; then
            echo "Installing Cypress..."
            npm install cypress --save-dev
        fi

        # Run E2E tests
        npm run e2e:ci

        # Check exit code
        if [ $? -ne 0 ]; then
            cd ..
            error_msg "Frontend end-to-end tests failed"
        fi
    fi

    cd ..

    echo -e "${GREEN}Web frontend tests completed successfully!${NC}"
}

# Function to run mobile frontend tests
run_mobile_tests() {
    step_msg "Running mobile frontend tests..."

    if [ ! -d "mobile-frontend" ]; then
        error_msg "Mobile frontend directory not found"
    fi

    cd mobile-frontend

    # Create report directories
    mkdir -p "../$TEST_REPORT_DIR/mobile-frontend"

    # Install dependencies if node_modules doesn't exist
    if [ ! -d "node_modules" ]; then
        echo "Installing dependencies..."
        npm install
    fi

    # Determine test types to run
    if [ "$RUN_UNIT" = true ]; then
        echo "Running mobile unit tests..."

        # Add coverage if requested
        local coverage_opts=""
        if [ "$GENERATE_COVERAGE" = true ]; then
            coverage_opts="--coverage --coverageDirectory=../$COVERAGE_REPORT_DIR/mobile-frontend"
            mkdir -p "../$COVERAGE_REPORT_DIR/mobile-frontend"
        fi

        # Run unit tests
        npm test -- --watchAll=false $coverage_opts

        # Check exit code
        if [ $? -ne 0 ]; then
            cd ..
            error_msg "Mobile unit tests failed"
        fi
    fi

    # Run E2E tests if requested
    if [ "$RUN_E2E" = true ]; then
        echo "Running mobile end-to-end tests..."

        # Check if Detox is installed
        if ! command_exists detox; then
            warning_msg "Detox is not installed. Skipping mobile E2E tests."
        else
            # Run E2E tests
            detox test --configuration ios.sim.release

            # Check exit code
            if [ $? -ne 0 ]; then
                cd ..
                error_msg "Mobile end-to-end tests failed"
            fi
        fi
    fi

    cd ..

    echo -e "${GREEN}Mobile frontend tests completed successfully!${NC}"
}

# Function to run AI services tests
run_ai_tests() {
    step_msg "Running AI services tests..."

    if [ ! -d "ai-services" ]; then
        error_msg "AI services directory not found"
    fi

    cd ai-services

    # Create report directories
    mkdir -p "../$TEST_REPORT_DIR/ai-services"

    # Check if virtual environment exists
    if [ ! -d "venv" ]; then
        echo "Creating virtual environment..."
        python3 -m venv venv
    fi

    # Activate virtual environment
    source venv/bin/activate

    # Install dependencies if requirements.txt exists
    if [ -f "requirements.txt" ]; then
        echo "Installing dependencies..."
        pip install -r requirements.txt
        pip install pytest pytest-cov
    fi

    # Determine test types to run
    if [ "$RUN_UNIT" = true ] || [ "$RUN_INTEGRATION" = true ]; then
        echo "Running AI service tests..."

        # Add coverage if requested
        local coverage_opts=""
        if [ "$GENERATE_COVERAGE" = true ]; then
            coverage_opts="--cov=. --cov-report=xml:../$COVERAGE_REPORT_DIR/ai-services/coverage.xml"
            mkdir -p "../$COVERAGE_REPORT_DIR/ai-services"
        fi

        # Run tests
        python -m pytest $coverage_opts --junitxml=../$TEST_REPORT_DIR/ai-services/test-results.xml

        # Check exit code
        if [ $? -ne 0 ]; then
            deactivate
            cd ..
            error_msg "AI service tests failed"
        fi
    fi

    # Deactivate virtual environment
    deactivate

    cd ..

    echo -e "${GREEN}AI services tests completed successfully!${NC}"
}

# Function to generate a consolidated test report
generate_test_report() {
    step_msg "Generating consolidated test report..."

    # Check if any test reports exist
    if [ ! -d "$TEST_REPORT_DIR" ]; then
        warning_msg "No test reports found. Skipping report generation."
        return
    fi

    # Create report directory
    mkdir -p "$TEST_REPORT_DIR/consolidated"

    # Generate HTML report
    echo "<!DOCTYPE html>
<html>
<head>
    <title>FinovaBank Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #333; }
        .summary { margin-bottom: 20px; }
        .component { margin-bottom: 30px; }
        .success { color: green; }
        .failure { color: red; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        tr:nth-child(even) { background-color: #f9f9f9; }
    </style>
</head>
<body>
    <h1>FinovaBank Test Report</h1>
    <div class='summary'>
        <h2>Summary</h2>
        <p>Generated on: $(date)</p>
    </div>" > "$TEST_REPORT_DIR/consolidated/index.html"

    # Add component reports
    for component in backend web-frontend mobile-frontend ai-services; do
        if [ -d "$TEST_REPORT_DIR/$component" ]; then
            echo "<div class='component'>
        <h2>$component</h2>" >> "$TEST_REPORT_DIR/consolidated/index.html"

            # Add test results if available
            if [ -f "$TEST_REPORT_DIR/$component/test-results.xml" ]; then
                # Parse XML and extract summary
                echo "<p>Test results available in $TEST_REPORT_DIR/$component/test-results.xml</p>" >> "$TEST_REPORT_DIR/consolidated/index.html"
            else
                echo "<p>No test results found for this component.</p>" >> "$TEST_REPORT_DIR/consolidated/index.html"
            fi

            echo "</div>" >> "$TEST_REPORT_DIR/consolidated/index.html"
        fi
    done

    # Add coverage reports if available
    if [ -d "$COVERAGE_REPORT_DIR" ]; then
        echo "<div class='component'>
        <h2>Coverage Reports</h2>" >> "$TEST_REPORT_DIR/consolidated/index.html"

        for component in backend web-frontend mobile-frontend ai-services; do
            if [ -d "$COVERAGE_REPORT_DIR/$component" ]; then
                echo "<p>Coverage report available for $component</p>" >> "$TEST_REPORT_DIR/consolidated/index.html"
            fi
        done

        echo "</div>" >> "$TEST_REPORT_DIR/consolidated/index.html"
    fi

    # Close HTML
    echo "</body>
</html>" >> "$TEST_REPORT_DIR/consolidated/index.html"

    echo -e "${GREEN}Test report generated: $TEST_REPORT_DIR/consolidated/index.html${NC}"
}

# Parse command line arguments
RUN_BACKEND=false
RUN_FRONTEND=false
RUN_MOBILE=false
RUN_AI=false
RUN_UNIT=false
RUN_INTEGRATION=false
RUN_E2E=false
GENERATE_COVERAGE=false
CI_MODE=false

while [ "$#" -gt 0 ]; do
    case "$1" in
        all)
            RUN_BACKEND=true
            RUN_FRONTEND=true
            RUN_MOBILE=true
            RUN_AI=true
            ;;
        backend)
            RUN_BACKEND=true
            ;;
        frontend)
            RUN_FRONTEND=true
            ;;
        mobile)
            RUN_MOBILE=true
            ;;
        ai)
            RUN_AI=true
            ;;
        --help)
            usage
            ;;
        --unit)
            RUN_UNIT=true
            ;;
        --integration)
            RUN_INTEGRATION=true
            ;;
        --e2e)
            RUN_E2E=true
            ;;
        --coverage)
            GENERATE_COVERAGE=true
            ;;
        --report-dir)
            TEST_REPORT_DIR="$2"
            shift
            ;;
        --coverage-dir)
            COVERAGE_REPORT_DIR="$2"
            shift
            ;;
        --timeout)
            TEST_TIMEOUT="$2"
            shift
            ;;
        --ci)
            CI_MODE=true
            ;;
        *)
            error_msg "Unknown option: $1"
            ;;
    esac
    shift
done

# If no component is specified, run all
if [ "$RUN_BACKEND" = false ] && [ "$RUN_FRONTEND" = false ] && [ "$RUN_MOBILE" = false ] && [ "$RUN_AI" = false ]; then
    RUN_BACKEND=true
    RUN_FRONTEND=true
    RUN_MOBILE=true
    RUN_AI=true
fi

# If no test type is specified, run all
if [ "$RUN_UNIT" = false ] && [ "$RUN_INTEGRATION" = false ] && [ "$RUN_E2E" = false ]; then
    RUN_UNIT=true
    RUN_INTEGRATION=true
    RUN_E2E=true
fi

# Main execution
echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}FinovaBank Testing Automation${NC}"
echo -e "${BLUE}======================================================${NC}"

# Check if we're in the right directory
if [ ! -f "README.md" ] || ! grep -q "FinovaBank" "README.md"; then
    error_msg "Please run this script from the root of the FinovaBank repository"
fi

# Create report directories
mkdir -p "$TEST_REPORT_DIR"
if [ "$GENERATE_COVERAGE" = true ]; then
    mkdir -p "$COVERAGE_REPORT_DIR"
fi

# Run tests for each component
if [ "$RUN_BACKEND" = true ]; then
    run_backend_tests
fi

if [ "$RUN_FRONTEND" = true ]; then
    run_frontend_tests
fi

if [ "$RUN_MOBILE" = true ]; then
    run_mobile_tests
fi

if [ "$RUN_AI" = true ]; then
    run_ai_tests
fi

# Generate consolidated test report
generate_test_report

echo -e "\n${GREEN}All tests completed successfully!${NC}"
echo -e "Test reports are available in: ${BLUE}$TEST_REPORT_DIR${NC}"
if [ "$GENERATE_COVERAGE" = true ]; then
    echo -e "Coverage reports are available in: ${BLUE}$COVERAGE_REPORT_DIR${NC}"
fi
echo -e "${BLUE}======================================================${NC}"

exit 0
