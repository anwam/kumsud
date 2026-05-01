#!/bin/bash

# PWA Update Detection Hook
# Detects when user is working with Service Worker registration in main.js
# and injects context about PWA update detection patterns
#
# Reads JSON from stdin and returns JSON with optional systemMessage injection

# Set strict error handling
set -e

# Read input from stdin
INPUT=$(cat)

# Extract the user's prompt/message if available
PROMPT=$(echo "$INPUT" | jq -r '.userMessage // empty' 2>/dev/null || echo "")
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // empty' 2>/dev/null || echo "")
FILE_PATH=$(echo "$INPUT" | jq -r '.filePath // empty' 2>/dev/null || echo "")

# Check if user is asking about or working with main.js, service worker, or PWA updates
IS_RELEVANT=0

if echo "$PROMPT" | grep -iq "main\.js\|service.*worker\|pwa.*update\|update.*detection\|update.*notification\|beforeinstallprompt\|registration\|sw\.js"; then
  IS_RELEVANT=1
fi

if echo "$FILE_PATH" | grep -q "main\.js"; then
  IS_RELEVANT=1
fi

if echo "$TOOL_NAME" | grep -iq "edit\|create.*file"; then
  # Check if they're editing main.js
  if echo "$PROMPT" | grep -q "main\.js"; then
    IS_RELEVANT=1
  fi
fi

# If relevant, check if update detection code already exists
HAS_UPDATE_DETECTION=0
if [ -f "src/main.js" ]; then
  if grep -q "updatefound\|statechange.*installed\|update.*available" "src/main.js"; then
    HAS_UPDATE_DETECTION=1
  fi
fi

# Build output JSON
OUTPUT='{}'

# If this is relevant and no update detection code exists, inject context
if [ $IS_RELEVANT -eq 1 ] && [ $HAS_UPDATE_DETECTION -eq 0 ]; then
  SYSTEM_MESSAGE="💡 **PWA Update Detection**: When registering the Service Worker in main.js, consider adding update detection. When a new version deploys, notify the user so they can refresh. 

Here's the pattern:
\`\`\`javascript
navigator.serviceWorker.register('/sw.js').then((registration) => {
  registration.addEventListener('updatefound', () => {
    const newWorker = registration.installing
    newWorker.addEventListener('statechange', () => {
      if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
        // New version ready! Show user a notification/toast
        console.log('✓ App update available. Refresh to apply.')
        // Trigger UI to show 'Update available' banner
      }
    })
  })
})
\`\`\`

See [PWA Instructions](../../instructions/pwa.instructions.md#prompt-user-to-update-optional) for full pattern."

  OUTPUT=$(jq -n --arg msg "$SYSTEM_MESSAGE" '
    {
      "continue": true,
      "systemMessage": $msg
    }
  ')
fi

# Output JSON (required by hook contract)
echo "$OUTPUT"

exit 0
