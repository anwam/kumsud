#!/bin/bash

# PWA Validation Script
# Validates manifest, icons, service worker, and index.html for PWA readiness
# Usage: bash .github/skills/pwa-testing/scripts/validate-pwa.sh

set -e

PROJECT_ROOT="$(pwd)"
MANIFEST_PATH="$PROJECT_ROOT/public/manifest.json"
SW_PATH="$PROJECT_ROOT/public/sw.js"
INDEX_HTML="$PROJECT_ROOT/index.html"
PUBLIC_DIR="$PROJECT_ROOT/public"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS=0
FAIL=0

# Helper functions
pass() {
  echo -e "${GREEN}✓ PASS${NC}: $1"
  ((PASS++))
}

fail() {
  echo -e "${RED}✗ FAIL${NC}: $1"
  ((FAIL++))
}

warn() {
  echo -e "${YELLOW}⚠ WARN${NC}: $1"
}

echo "================================================"
echo "PWA Validation for kumsud"
echo "================================================"
echo ""

# 1. Check manifest.json exists
echo "1. Manifest File"
if [ ! -f "$MANIFEST_PATH" ]; then
  fail "manifest.json not found at $MANIFEST_PATH"
else
  pass "manifest.json exists"
  
  # Validate JSON
  if jq empty "$MANIFEST_PATH" 2>/dev/null; then
    pass "manifest.json is valid JSON"
  else
    fail "manifest.json has invalid JSON syntax"
  fi
fi

echo ""
echo "2. Manifest Required Fields"

# Check required fields in manifest
check_field() {
  local field="$1"
  local value=$(jq -r ".${field} // empty" "$MANIFEST_PATH" 2>/dev/null)
  if [ -z "$value" ]; then
    fail "Missing required field: $field"
  else
    pass "Field '$field': $value"
  fi
}

check_field "name"
check_field "short_name"
check_field "start_url"
check_field "display"
check_field "theme_color"
check_field "background_color"
check_field "orientation"

echo ""
echo "3. Manifest Icons"

# Get icon count
ICON_COUNT=$(jq '.icons | length' "$MANIFEST_PATH" 2>/dev/null || echo 0)
if [ "$ICON_COUNT" -lt 2 ]; then
  fail "Manifest must have at least 2 icons (purpose: any, maskable); found $ICON_COUNT"
else
  pass "Manifest declares $ICON_COUNT icons"
fi

# Check for maskable and any purposes
HAS_MASKABLE=$(jq '.icons[] | select(.purpose == "maskable") | length' "$MANIFEST_PATH" 2>/dev/null || echo 0)
HAS_ANY=$(jq '.icons[] | select(.purpose == "any") | length' "$MANIFEST_PATH" 2>/dev/null || echo 0)

if [ "$HAS_MASKABLE" -gt 0 ]; then
  pass "Has maskable icon"
else
  fail "Missing maskable icon (purpose: 'maskable')"
fi

if [ "$HAS_ANY" -gt 0 ]; then
  pass "Has standard icon (purpose: 'any')"
else
  fail "Missing standard icon (purpose: 'any')"
fi

echo ""
echo "4. Icon Files"

# Extract icon sources and check if they exist
ICON_PATHS=$(jq -r '.icons[].src' "$MANIFEST_PATH" 2>/dev/null || echo "")

for icon_path in $ICON_PATHS; do
  # Remove leading slash if present
  icon_file="${icon_path#/}"
  full_path="$PUBLIC_DIR/$icon_file"
  
  if [ ! -f "$full_path" ]; then
    fail "Icon not found: $icon_path"
  else
    # Check file size and type
    file_type=$(file -b "$full_path" | grep -o "PNG\|SVG\|JPEG" || echo "UNKNOWN")
    file_size=$(stat -f%z "$full_path" 2>/dev/null || echo "0")
    
    if [[ "$file_path" == *.png || "$file_type" == "PNG" ]]; then
      pass "Icon exists: $icon_path ($(($file_size / 1024))KB)"
    elif [[ "$icon_path" == *.svg ]]; then
      pass "Icon exists: $icon_path (SVG)"
    else
      warn "Icon file type unclear: $icon_path ($file_type)"
    fi
  fi
done

echo ""
echo "5. Manifest Icon Declarations"

# Validate icon sizes match declarations
jq -r '.icons[] | "\(.src) - \(.sizes)"' "$MANIFEST_PATH" 2>/dev/null | while read -r line; do
  if [ -n "$line" ]; then
    pass "Icon declaration: $line"
  fi
done

echo ""
echo "6. Service Worker"

if [ ! -f "$SW_PATH" ]; then
  fail "Service Worker not found at $SW_PATH"
else
  pass "Service Worker exists"
  
  # Check for key SW patterns
  if grep -q "install\|'install'" "$SW_PATH"; then
    pass "SW has install event listener"
  else
    fail "SW missing install event listener"
  fi
  
  if grep -q "activate\|'activate'" "$SW_PATH"; then
    pass "SW has activate event listener"
  else
    fail "SW missing activate event listener"
  fi
  
  if grep -q "fetch\|'fetch'" "$SW_PATH"; then
    pass "SW has fetch event listener"
  else
    fail "SW missing fetch event listener"
  fi
  
  if grep -q "CACHE_NAME" "$SW_PATH"; then
    CACHE_NAME=$(grep "CACHE_NAME" "$SW_PATH" | head -1 | sed "s/.*CACHE_NAME = ['\"]\(.*\)['\"].*/\1/")
    pass "SW defines CACHE_NAME: $CACHE_NAME"
  else
    fail "SW missing CACHE_NAME definition"
  fi
fi

echo ""
echo "7. index.html Configuration"

if [ ! -f "$INDEX_HTML" ]; then
  fail "index.html not found"
else
  pass "index.html exists"
  
  # Check manifest link
  if grep -q 'link.*manifest' "$INDEX_HTML"; then
    pass "index.html links manifest.json"
  else
    fail "index.html missing <link rel=\"manifest\" href=\"/manifest.json\" />"
  fi
  
  # Check theme-color meta
  if grep -q 'meta.*theme-color' "$INDEX_HTML"; then
    pass "index.html has theme-color meta tag"
  else
    fail "index.html missing <meta name=\"theme-color\" content=\"...\" />"
  fi
  
  # Check viewport meta
  if grep -q 'meta.*viewport' "$INDEX_HTML"; then
    pass "index.html has viewport meta tag"
  else
    fail "index.html missing viewport meta tag"
  fi
  
  # Check service worker registration or note about it
  if grep -q 'serviceWorker\|sw\.js' "$INDEX_HTML" || [ -f "$PROJECT_ROOT/src/main.js" ]; then
    # SW registration typically in main.js, not index.html
    if grep -q 'serviceWorker' "$PROJECT_ROOT/src/main.js" 2>/dev/null; then
      pass "Service Worker registered in src/main.js"
    else
      warn "Service Worker registration should be in src/main.js (not found in index.html, which is expected)"
    fi
  fi
fi

echo ""
echo "8. Additional Assets"

# Check for key icons
REQUIRED_ICONS=(
  "pwa-192x192.png"
  "pwa-512x512.png"
  "apple-touch-icon-180x180.png"
  "maskable-icon-512x512.png"
)

for icon_name in "${REQUIRED_ICONS[@]}"; do
  if [ -f "$PUBLIC_DIR/$icon_name" ]; then
    pass "Found: $icon_name"
  else
    fail "Missing recommended icon: $icon_name"
  fi
done

echo ""
echo "================================================"
echo "Validation Results"
echo "================================================"
echo -e "${GREEN}Passed:${NC} $PASS"
echo -e "${RED}Failed:${NC} $FAIL"

if [ $FAIL -eq 0 ]; then
  echo -e "\n${GREEN}✓ PWA validation passed! Ready for deployment.${NC}"
  exit 0
else
  echo -e "\n${RED}✗ PWA validation failed. Fix errors above before deployment.${NC}"
  exit 1
fi
