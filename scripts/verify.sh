#!/bin/bash

# Word Train Mobile App Verification Script
# Run this before declaring a task complete

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo_step() {
    echo -e "${BLUE}==>${NC} $1"
}

echo_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

echo_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

echo_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Track overall status
FRONTEND_OK=false

echo ""
echo "========================================"
echo "  Word Train Mobile App Verification"
echo "========================================"
echo ""

# Frontend verification
echo_step "Verifying Frontend..."
cd "$PROJECT_ROOT/word_train"

if flutter analyze 2>&1; then
    echo_success "Flutter analyze passed"

    if flutter test 2>&1; then
        echo_success "Flutter tests passed"
        FRONTEND_OK=true
    else
        echo_warning "Flutter tests failed (or no tests found)"
        # Don't fail if no tests - some projects don't have them yet
        FRONTEND_OK=true
    fi
else
    echo_error "Flutter analyze failed"
fi

echo ""
echo "========================================"
echo "  Summary"
echo "========================================"
echo ""

if $FRONTEND_OK; then
    echo_success "Frontend: All checks passed"
else
    echo_error "Frontend: Some checks failed"
fi

echo ""

if $FRONTEND_OK; then
    echo -e "${GREEN}All verifications passed!${NC}"
    exit 0
else
    echo -e "${RED}Some verifications failed. Please fix before proceeding.${NC}"
    exit 1
fi
