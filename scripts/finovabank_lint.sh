#!/bin/bash
# =====================================================
# FinovaBank Code Quality Automation Script
# =====================================================
# This script automates code linting, formatting, and quality
# checks across all components of the FinovaBank platform.
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
REPORT_DIR="./lint-reports"
FIX_ISSUES=false
VERBOSE=false

# Function to display usage information
usage() {
    echo -e "${BLUE}Usage:${NC} $0 [options] [components]"
    echo -e ""
    echo -e "${BLUE}Components:${NC}"
    echo -e "  all                  Check all components (default)"
    echo -e "  backend              Check backend services only"
    echo -e "  frontend             Check web frontend only"
    echo -e "  mobile               Check mobile frontend only"
    echo -e "  ai                   Check AI services only"
    echo -e ""
    echo -e "${BLUE}Options:${NC}"
    echo -e "  --help               Display this help message"
    echo -e "  --fix                Automatically fix issues where possible"
    echo -e "  --report-dir DIR     Report directory (default: $REPORT_DIR)"
    echo -e "  --verbose            Show detailed output"
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

# Function to lint backend code
lint_backend() {
    step_msg "Linting backend code..."

    if [ ! -d "backend" ]; then
        error_msg "Backend directory not found"
    fi

    cd backend

    # Create report directory
    mkdir -p "../$REPORT_DIR/backend"

    # Check if Maven wrapper exists
    if [ ! -f "mvnw" ]; then
        echo "Maven wrapper not found, downloading..."
        mvn -N io.takari:maven:wrapper
        chmod +x mvnw
    fi

    # Run Checkstyle
    echo "Running Checkstyle..."
    ./mvnw checkstyle:check -Dcheckstyle.output.format=xml -Dcheckstyle.output.file="../$REPORT_DIR/backend/checkstyle-result.xml"

    # Run SpotBugs if available
    if grep -q "spotbugs" "pom.xml"; then
        echo "Running SpotBugs..."
        ./mvnw spotbugs:check -Dspotbugs.xmlOutput=true -Dspotbugs.outputDirectory="../$REPORT_DIR/backend"
    fi

    # Run PMD if available
    if grep -q "pmd" "pom.xml"; then
        echo "Running PMD..."
        ./mvnw pmd:check -Dpmd.outputDirectory="../$REPORT_DIR/backend"
    fi

    # If fix flag is set, run formatter
    if [ "$FIX_ISSUES" = true ]; then
        echo "Formatting backend code..."
        ./mvnw formatter:format
    fi

    cd ..

    echo -e "${GREEN}Backend linting completed!${NC}"
}

# Function to lint web frontend code
lint_frontend() {
    step_msg "Linting web frontend code..."

    if [ ! -d "web-frontend" ]; then
        error_msg "Web frontend directory not found"
    fi

    cd web-frontend

    # Create report directory
    mkdir -p "../$REPORT_DIR/web-frontend"

    # Install dependencies if node_modules doesn't exist
    if [ ! -d "node_modules" ]; then
        echo "Installing dependencies..."
        npm install
    fi

    # Check if ESLint is installed
    if [ ! -f "node_modules/.bin/eslint" ]; then
        echo "Installing ESLint..."
        npm install eslint --save-dev
    fi

    # Run ESLint
    echo "Running ESLint..."
    local fix_flag=""
    if [ "$FIX_ISSUES" = true ]; then
        fix_flag="--fix"
    fi

    local format_flag="--format json"
    if [ "$VERBOSE" = true ]; then
        format_flag="--format stylish"
    fi

    npx eslint . $fix_flag $format_flag --output-file "../$REPORT_DIR/web-frontend/eslint-results.json"

    # Check if Prettier is installed
    if [ -f "package.json" ] && grep -q "prettier" "package.json"; then
        echo "Running Prettier..."

        if [ "$FIX_ISSUES" = true ]; then
            npx prettier --write "src/**/*.{js,jsx,ts,tsx,json,css,scss,md}"
        else
            npx prettier --check "src/**/*.{js,jsx,ts,tsx,json,css,scss,md}" > "../$REPORT_DIR/web-frontend/prettier-results.txt"
        fi
    fi

    # Check TypeScript if applicable
    if [ -f "tsconfig.json" ]; then
        echo "Running TypeScript compiler check..."
        npx tsc --noEmit
    fi

    cd ..

    echo -e "${GREEN}Web frontend linting completed!${NC}"
}

# Function to lint mobile frontend code
lint_mobile() {
    step_msg "Linting mobile frontend code..."

    if [ ! -d "mobile-frontend" ]; then
        error_msg "Mobile frontend directory not found"
    fi

    cd mobile-frontend

    # Create report directory
    mkdir -p "../$REPORT_DIR/mobile-frontend"

    # Install dependencies if node_modules doesn't exist
    if [ ! -d "node_modules" ]; then
        echo "Installing dependencies..."
        npm install
    fi

    # Check if ESLint is installed
    if [ ! -f "node_modules/.bin/eslint" ]; then
        echo "Installing ESLint..."
        npm install eslint --save-dev
    fi

    # Run ESLint
    echo "Running ESLint..."
    local fix_flag=""
    if [ "$FIX_ISSUES" = true ]; then
        fix_flag="--fix"
    fi

    local format_flag="--format json"
    if [ "$VERBOSE" = true ]; then
        format_flag="--format stylish"
    fi

    npx eslint . $fix_flag $format_flag --output-file "../$REPORT_DIR/mobile-frontend/eslint-results.json"

    # Check if Prettier is installed
    if [ -f "package.json" ] && grep -q "prettier" "package.json"; then
        echo "Running Prettier..."

        if [ "$FIX_ISSUES" = true ]; then
            npx prettier --write "src/**/*.{js,jsx,ts,tsx,json,css,scss,md}"
        else
            npx prettier --check "src/**/*.{js,jsx,ts,tsx,json,css,scss,md}" > "../$REPORT_DIR/mobile-frontend/prettier-results.txt"
        fi
    fi

    # Check TypeScript if applicable
    if [ -f "tsconfig.json" ]; then
        echo "Running TypeScript compiler check..."
        npx tsc --noEmit
    fi

    cd ..

    echo -e "${GREEN}Mobile frontend linting completed!${NC}"
}

# Function to lint AI services code
lint_ai() {
    step_msg "Linting AI services code..."

    if [ ! -d "ai-services" ]; then
        error_msg "AI services directory not found"
    fi

    cd ai-services

    # Create report directory
    mkdir -p "../$REPORT_DIR/ai-services"

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
    fi

    # Install linting tools
    echo "Installing linting tools..."
    pip install flake8 pylint black isort mypy

    # Run Flake8
    echo "Running Flake8..."
    flake8 . --output-file="../$REPORT_DIR/ai-services/flake8-results.txt"

    # Run Pylint
    echo "Running Pylint..."
    pylint --output-format=text . > "../$REPORT_DIR/ai-services/pylint-results.txt" || true

    # Run MyPy if applicable
    if [ -f "mypy.ini" ] || [ -f "setup.cfg" ] && grep -q "\[mypy\]" "setup.cfg"; then
        echo "Running MyPy..."
        mypy . --txt-report="../$REPORT_DIR/ai-services/mypy-results.txt" || true
    fi

    # If fix flag is set, run formatters
    if [ "$FIX_ISSUES" = true ]; then
        echo "Formatting AI services code..."
        black .
        isort .
    fi

    # Deactivate virtual environment
    deactivate

    cd ..

    echo -e "${GREEN}AI services linting completed!${NC}"
}

# Function to generate a consolidated lint report
generate_lint_report() {
    step_msg "Generating consolidated lint report..."

    # Check if any lint reports exist
    if [ ! -d "$REPORT_DIR" ]; then
        warning_msg "No lint reports found. Skipping report generation."
        return
    fi

    # Create report directory
    mkdir -p "$REPORT_DIR/consolidated"

    # Generate HTML report
    echo "<!DOCTYPE html>
<html>
<head>
    <title>FinovaBank Code Quality Report</title>
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
    <h1>FinovaBank Code Quality Report</h1>
    <div class='summary'>
        <h2>Summary</h2>
        <p>Generated on: $(date)</p>
    </div>" > "$REPORT_DIR/consolidated/index.html"

    # Add component reports
    for component in backend web-frontend mobile-frontend ai-services; do
        if [ -d "$REPORT_DIR/$component" ]; then
            echo "<div class='component'>
        <h2>$component</h2>
        <table>
            <tr>
                <th>Tool</th>
                <th>Status</th>
                <th>Report</th>
            </tr>" >> "$REPORT_DIR/consolidated/index.html"

            # Check for specific tool reports
            case $component in
                backend)
                    if [ -f "$REPORT_DIR/$component/checkstyle-result.xml" ]; then
                        echo "<tr>
                <td>Checkstyle</td>
                <td>Completed</td>
                <td><a href='../backend/checkstyle-result.xml'>View Report</a></td>
            </tr>" >> "$REPORT_DIR/consolidated/index.html"
                    fi
                    ;;
                web-frontend|mobile-frontend)
                    if [ -f "$REPORT_DIR/$component/eslint-results.json" ]; then
                        echo "<tr>
                <td>ESLint</td>
                <td>Completed</td>
                <td><a href='../$component/eslint-results.json'>View Report</a></td>
            </tr>" >> "$REPORT_DIR/consolidated/index.html"
                    fi
                    if [ -f "$REPORT_DIR/$component/prettier-results.txt" ]; then
                        echo "<tr>
                <td>Prettier</td>
                <td>Completed</td>
                <td><a href='../$component/prettier-results.txt'>View Report</a></td>
            </tr>" >> "$REPORT_DIR/consolidated/index.html"
                    fi
                    ;;
                ai-services)
                    if [ -f "$REPORT_DIR/$component/flake8-results.txt" ]; then
                        echo "<tr>
                <td>Flake8</td>
                <td>Completed</td>
                <td><a href='../ai-services/flake8-results.txt'>View Report</a></td>
            </tr>" >> "$REPORT_DIR/consolidated/index.html"
                    fi
                    if [ -f "$REPORT_DIR/$component/pylint-results.txt" ]; then
                        echo "<tr>
                <td>Pylint</td>
                <td>Completed</td>
                <td><a href='../ai-services/pylint-results.txt'>View Report</a></td>
            </tr>" >> "$REPORT_DIR/consolidated/index.html"
                    fi
                    if [ -f "$REPORT_DIR/$component/mypy-results.txt" ]; then
                        echo "<tr>
                <td>MyPy</td>
                <td>Completed</td>
                <td><a href='../ai-services/mypy-results.txt'>View Report</a></td>
            </tr>" >> "$REPORT_DIR/consolidated/index.html"
                    fi
                    ;;
            esac

            echo "        </table>
    </div>" >> "$REPORT_DIR/consolidated/index.html"
        fi
    done

    # Close HTML
    echo "</body>
</html>" >> "$REPORT_DIR/consolidated/index.html"

    echo -e "${GREEN}Code quality report generated: $REPORT_DIR/consolidated/index.html${NC}"
}

# Parse command line arguments
RUN_BACKEND=false
RUN_FRONTEND=false
RUN_MOBILE=false
RUN_AI=false
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
        --fix)
            FIX_ISSUES=true
            ;;
        --report-dir)
            REPORT_DIR="$2"
            shift
            ;;
        --verbose)
            VERBOSE=true
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

# Main execution
echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}FinovaBank Code Quality Automation${NC}"
echo -e "${BLUE}======================================================${NC}"

# Check if we're in the right directory
if [ ! -f "README.md" ] || ! grep -q "FinovaBank" "README.md"; then
    error_msg "Please run this script from the root of the FinovaBank repository"
fi

# Create report directory
mkdir -p "$REPORT_DIR"

# Run linting for each component
if [ "$RUN_BACKEND" = true ]; then
    lint_backend
fi

if [ "$RUN_FRONTEND" = true ]; then
    lint_frontend
fi

if [ "$RUN_MOBILE" = true ]; then
    lint_mobile
fi

if [ "$RUN_AI" = true ]; then
    lint_ai
fi

# Generate consolidated lint report
generate_lint_report

echo -e "\n${GREEN}Code quality checks completed!${NC}"
echo -e "Lint reports are available in: ${BLUE}$REPORT_DIR${NC}"
echo -e "${BLUE}======================================================${NC}"

exit 0
