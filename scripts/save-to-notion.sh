#!/bin/bash
# ~/.openclaw/scripts/save-to-notion.sh
# Save a URL to Notion Resources Hub with AI-generated description

set -e

URL="$1"
TITLE="$2"
DESCRIPTION="$3"
CATEGORY="$4"

if [[ -z "$URL" ]]; then
  echo "Usage: save-to-notion.sh <url> [title] [description] [category]"
  exit 1
fi

# Load credentials
source ~/.openclaw/.notion-api.env

# If title not provided, extract from URL
if [[ -z "$TITLE" ]]; then
  TITLE=$(curl -s "$URL" | grep -o '<title>[^<]*</title>' | sed 's/<[^>]*>//g' | head -1 || echo "Resource")
fi

# If description not provided, use placeholder
if [[ -z "$DESCRIPTION" ]]; then
  DESCRIPTION="Saved from Telegram"
fi

# If category not provided, use General
if [[ -z "$CATEGORY" ]]; then
  CATEGORY="General"
fi

# Create page in Notion
curl -s -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer $NOTION_TOKEN" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d "{
    \"parent\": { \"database_id\": \"$NOTION_RESOURCES_DB\" },
    \"properties\": {
      \"Resource\": {
        \"title\": [{ \"text\": { \"content\": \"$TITLE\" } }]
      },
      \"URL\": { \"url\": \"$URL\" },
      \"Description\": {
        \"rich_text\": [{ \"text\": { \"content\": \"$DESCRIPTION\" } }]
      },
      \"Category\": {
        \"multi_select\": [{ \"name\": \"$CATEGORY\" }]
      }
    }
  }" | python3 -c "import sys, json; d=json.load(sys.stdin); print('✅ Saved!' if d.get('object')=='page' else f'❌ Error: {d.get(\"message\", \"Unknown\")}')"

echo ""
echo "Title: $TITLE"
echo "URL: $URL"
echo "Category: $CATEGORY"