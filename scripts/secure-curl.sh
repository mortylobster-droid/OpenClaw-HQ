#!/bin/bash
# ~/.openclaw/scripts/secure-curl.sh
# Wrapper for curl with logging and endpoint validation

ALLOWED_ENDPOINTS=(
  "github.com"
  "api.github.com"
  "gmail.googleapis.com"
  "api.telegram.org"
  "*.cloudflare.com"
  "*.trycloudflare.com"
  "api.moonshot.cn"
  "localhost:5678"
  "n8n.mortyautomations.com"
)

LOG_FILE="$HOME/.openclaw/logs/network.log"
mkdir -p "$(dirname "$LOG_FILE")"

# Extract hostname from URL
extract_host() {
  local url="$1"
  echo "$url" | sed -E 's|^https?://([^/]+).*|\1|'
}

# Check if endpoint is allowed
is_allowed() {
  local host="$1"
  for pattern in "${ALLOWED_ENDPOINTS[@]}"; do
    if [[ "$host" == $pattern ]] || [[ "$host" == *"$pattern" ]]; then
      return 0
    fi
  done
  return 1
}

# Log the request
log_request() {
  local method="$1"
  local url="$2"
  local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  echo "[$timestamp] $method $url" >> "$LOG_FILE"
}

# Parse arguments to find URL
url=""
method="GET"
for ((i=1; i<=$#; i++)); do
  arg="${!i}"
  if [[ "$arg" == http* ]]; then
    url="$arg"
  elif [[ "$arg" == "-X" ]] || [[ "$arg" == "--request" ]]; then
    next=$((i+1))
    method="${!next}"
  fi
done

if [[ -z "$url" ]]; then
  echo "ERROR: No URL provided" >&2
  exit 1
fi

host=$(extract_host "$url")

# Check if allowed
if ! is_allowed "$host"; then
  echo "⚠️  SECURITY: Request to non-allowlisted endpoint" >&2
  echo "    URL: $url" >&2
  echo "    Host: $host" >&2
  echo "    This request requires explicit approval." >&2
  exit 1
fi

# Log and execute
log_request "$method" "$url"
exec /usr/bin/curl "$@"