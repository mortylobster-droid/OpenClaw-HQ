#!/bin/bash
# ~/.openclaw/scripts/security-audit.sh
# Weekly security audit script

set -e

LOG_FILE="$HOME/.openclaw/logs/security-audit.log"
REPORT_FILE="$HOME/.openclaw/logs/security-report-$(date +%Y-%m-%d).md"
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-6026695075}"

mkdir -p "$(dirname "$LOG_FILE")"

# Logging function
log() {
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $*" | tee -a "$LOG_FILE"
}

# Start report
cat > "$REPORT_FILE" << EOF
# Security Audit Report

**Date:** $(date +%Y-%m-%d)  
**Week:** $(date +%U)  
**System:** Mac mini (Brain Agent)

---

## Summary

EOF

log "Starting security audit..."

# 1. Credential File Permissions
echo "## 1. Credential File Permissions" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| File | Permissions | Status |" >> "$REPORT_FILE"
echo "|------|-------------|--------|" >> "$REPORT_FILE"

CRED_ISSUES=0
find ~/.openclaw -name "*.env" -o -name "*token*" -o -name "*credential*" 2>/dev/null | while read -r file; do
  perms=$(stat -f "%Lp" "$file" 2>/dev/null || stat -c "%a" "$file" 2>/dev/null || echo "unknown")
  if [[ "$perms" == "600" ]]; then
    echo "| \`$file\` | $perms | ✅ OK |" >> "$REPORT_FILE"
  else
    echo "| \`$file\` | $perms | ⚠️ WARNING |" >> "$REPORT_FILE"
    CRED_ISSUES=$((CRED_ISSUES + 1))
  fi
done

echo "" >> "$REPORT_FILE"

# 2. Active Processes
echo "## 2. Active Processes" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "\`\`\`" >> "$REPORT_FILE"
ps aux | grep -E "(cloudflared|n8n|docker|openclaw)" | grep -v grep >> "$REPORT_FILE" || echo "No matching processes" >> "$REPORT_FILE"
echo "\`\`\`" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 3. Network Activity
echo "## 3. Recent Network Activity (Last 7 Days)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
if [[ -f ~/.openclaw/logs/network.log ]]; then
  echo "\`\`\`" >> "$REPORT_FILE"
  tail -50 ~/.openclaw/logs/network.log >> "$REPORT_FILE" || echo "No network log" >> "$REPORT_FILE"
  echo "\`\`\`" >> "$REPORT_FILE"
else
  echo "_No network log found_" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# 4. File System Activity
echo "## 4. File System Activity" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "- Temporary files (last 7 days):" >> "$REPORT_FILE"
find /tmp -name "openclaw*" -mtime -7 2>/dev/null | wc -l | xargs echo "  - Count:" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 5. Docker Containers
echo "## 5. Docker Containers" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "\`\`\`" >> "$REPORT_FILE"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null >> "$REPORT_FILE" || echo "Docker not running" >> "$REPORT_FILE"
echo "\`\`\`" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 6. Tunnel Status
echo "## 6. Cloudflare Tunnel Status" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "\`\`\`" >> "$REPORT_FILE"
cloudflared tunnel info n8n-morty 2>/dev/null >> "$REPORT_FILE" || echo "Tunnel not found" >> "$REPORT_FILE"
echo "\`\`\`" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Summary
echo "## Summary" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
if [[ $CRED_ISSUES -gt 0 ]]; then
  echo "⚠️ **$CRED_ISSUES credential files with incorrect permissions**" >> "$REPORT_FILE"
else
  echo "✅ **All credential files properly secured (600 permissions)**" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "*Automated security audit completed*" >> "$REPORT_FILE"

log "Security audit completed. Report: $REPORT_FILE"

# Send to Telegram if configured
if [[ -n "$TELEGRAM_BOT_TOKEN" ]]; then
  SUMMARY=$(cat << EOF
🛡️ Weekly Security Audit

📅 $(date +%Y-%m-%d) | Week $(date +%U)

$(if [[ $CRED_ISSUES -gt 0 ]]; then echo "⚠️ $CRED_ISSUES credential permission issues"; else echo "✅ All credentials secure"; fi)

📁 Full report:
$REPORT_FILE

🤖 _Brain Agent (Rick)_
EOF
)
  
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -H "Content-Type: application/json" \
    -d "{
      \"chat_id\": \"${TELEGRAM_CHAT_ID}\",
      \"text\": \"$(echo "$SUMMARY" | sed 's/"/\\"/g')\",
      \"parse_mode\": \"Markdown\"
    }" > /dev/null 2>&1 || log "Failed to send Telegram notification"
fi

echo "$REPORT_FILE"