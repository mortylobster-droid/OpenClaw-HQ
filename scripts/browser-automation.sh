#!/bin/bash
# ~/.openclaw/scripts/browser-automation.sh
# Safe browser automation with user approval

URL="$1"
PURPOSE="$2"

if [[ -z "$URL" ]]; then
  echo "Usage: browser-automation.sh <url> <purpose>"
  exit 1
fi

# Check if user is logged into sensitive services
# This is a heuristic - in practice, you'd need more sophisticated detection
SENSITIVE_DOMAINS=(
  "chat.openai.com"
  "chatgpt.com"
  "claude.ai"
  "gmail.com"
  "mail.google.com"
  "facebook.com"
  "twitter.com"
  "x.com"
  "linkedin.com"
  "instagram.com"
  "bank"
  "paypal.com"
  "stripe.com"
)

is_sensitive() {
  local url="$1"
  for domain in "${SENSITIVE_DOMAINS[@]}"; do
    if [[ "$url" == *"$domain"* ]]; then
      return 0
    fi
  done
  return 1
}

# Log the request
LOG_FILE="$HOME/.openclaw/logs/browser-automation.log"
mkdir -p "$(dirname "$LOG_FILE")"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] REQUEST: $URL | Purpose: $PURPOSE" >> "$LOG_FILE"

# Check if sensitive
if is_sensitive "$URL"; then
  echo "⚠️  SECURITY WARNING"
  echo ""
  echo "You appear to be logged into sensitive services."
  echo "URL: $URL"
  echo "Purpose: $PURPOSE"
  echo ""
  echo "Options:"
  echo "1. Approve (proceed with caution)"
  echo "2. Use private window (recommended)"
  echo "3. Cancel (find alternative)"
  echo ""
  read -p "Choice [1-3]: " choice
  
  case $choice in
    1)
      echo "Proceeding with user approval..."
      echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] APPROVED: $URL" >> "$LOG_FILE"
      open "$URL"
      ;;
    2)
      echo "Opening in private window..."
      echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] PRIVATE: $URL" >> "$LOG_FILE"
      # macOS Safari private window
      osascript -e 'tell application "Safari" to make new document with properties {URL:"'$URL'"}'
      osascript -e 'tell application "Safari" to set private browsing of current tab of window 1 to true'
      ;;
    *)
      echo "Cancelled by user"
      echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] CANCELLED: $URL" >> "$LOG_FILE"
      exit 1
      ;;
  esac
else
  # Non-sensitive URL, log and proceed
  echo "Opening: $URL"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] AUTO: $URL" >> "$LOG_FILE"
  open "$URL"
fi