# Social Media Scraping Strategy

> **Goal:** Full browsing/scraping access to YouTube, X (Twitter), and Reddit with minimal API keys and accounts. Prioritize accountless scraping where possible.

---

## Quick Summary

| Platform | Tool | API Key? | Account? | Reliability | Best For |
|----------|------|----------|----------|-------------|----------|
| **YouTube** | scrapetube + yt-dlp | ❌ No | ❌ No | ⭐⭐⭐⭐⭐ | Channels, playlists, transcripts |
| **X/Twitter** | twikit | ❌ No | ✅ Yes* | ⭐⭐⭐ | Search, tweets, user profiles |
| **X/Twitter** | inference.sh | ✅ Yes | ❌ No | ⭐⭐⭐⭐⭐ | Posting, reliable API |
| **Reddit** | URS (PRAW) | ✅ Yes | ✅ Yes | ⭐⭐⭐⭐ | Full subreddit/redditor scraping |
| **Reddit** | pushshift (limited) | ❌ No | ❌ No | ⭐⭐ | Historical data only |

\* Twikit requires login credentials (username/password) but no API key

---

## 1. YouTube Strategy (No API Key / No Account)

### Primary Tool: `scrapetube` + `yt-dlp`

**Installation:**
```bash
pip install scrapetube yt-dlp
```

**Capabilities:**
- ✅ Channel video listings
- ✅ Playlist scraping
- ✅ Search results
- ✅ Transcripts/subtitles (manual + auto-generated)
- ✅ Video metadata (title, views, duration, etc.)

**Usage Examples:**

```python
# scrapetube - Get all videos from a channel
import scrapetube

videos = scrapetube.get_channel("UCCezIgC97PvUuR4_gbFUs5g")
for video in videos:
    print(f"{video['videoId']}: {video['title']['runs'][0]['text']}")
```

```bash
# yt-dlp - Download transcripts
yt-dlp --write-auto-sub --skip-download --output "transcript" "VIDEO_URL"

# Convert to plain text (deduplicated)
python3 -c "
import re
seen = set()
with open('transcript.en.vtt', 'r') as f:
    for line in f:
        line = line.strip()
        if line and not line.startswith('WEBVTT') and '-->' not in line:
            clean = re.sub('<[^>]*>', '', line)
            if clean and clean not in seen:
                print(clean)
                seen.add(clean)
" > transcript.txt
```

**Rate Limits:** Very generous. YouTube's internal endpoints are relatively open.

**Reliability:** ⭐⭐⭐⭐⭐ Excellent. scrapetube and yt-dlp are mature, actively maintained.

---

## 2. X/Twitter Strategy (Credential Trade-offs)

### Option A: `twikit` (No API Key, Account Required)

**Trade-off:** Free and unlimited, but requires a Twitter account login.

**Installation:**
```bash
pip install twikit
```

**Capabilities:**
- ✅ Search tweets
- ✅ Get user tweets
- ✅ Get trending topics
- ✅ Post tweets (if needed)
- ✅ Send DMs
- ✅ User profiles

**Usage:**
```python
import asyncio
from twikit import Client

client = Client('en-US')

async def main():
    # Login (one-time, saves cookies)
    await client.login(
        auth_info_1='your_username',
        auth_info_2='your_email@example.com',
        password='your_password',
        cookies_file='cookies.json'  # Reuse cookies after first login
    )
    
    # Search tweets
    tweets = await client.search_tweet('python', 'Latest')
    for tweet in tweets:
        print(f"@{tweet.user.name}: {tweet.text}")

asyncio.run(main())
```

**Account Risk:** Twitter may suspend scraper accounts. Use a burner account.

**Reliability:** ⭐⭐⭐ Moderate. Works well but Twitter changes their frontend frequently.

---

### Option B: `inference.sh` (API Key Required, No Account)

**Trade-off:** Requires API key, but no Twitter account needed. More reliable.

**Installation:**
```bash
curl -fsSL https://cli.inference.sh | sh && infsh login
```

**Capabilities:**
- ✅ Post tweets
- ✅ Get tweets by ID
- ✅ Like/retweet
- ✅ Follow users
- ✅ Send DMs

**Usage:**
```bash
# Post a tweet
infsh app run x/post-tweet --input '{"text": "Hello from inference.sh!"}'

# Get tweet details
infsh app run x/post-get --input '{"tweet_id": "1234567890"}'

# Get user profile
infsh app run x/user-get --input '{"username": "OpenAI"}'
```

**Cost:** inference.sh has free tier; paid plans for higher volume.

**Reliability:** ⭐⭐⭐⭐⭐ Excellent. Official API wrapper, stable.

---

## 3. Reddit Strategy (API Key + Account Required)

### Primary Tool: `URS` (Universal Reddit Scraper)

**Trade-off:** Requires Reddit API credentials, but provides comprehensive scraping.

**Installation:**
```bash
pip install urs
```

**Setup (requires Reddit account + app):**
1. Go to https://www.reddit.com/prefs/apps
2. Create a "script" app
3. Get `client_id` and `client_secret`
4. Store in `praw.ini` or environment variables

**Capabilities:**
- ✅ Subreddit scraping (hot/new/top/controversial)
- ✅ Redditor scraping (user history)
- ✅ Submission + comments scraping
- ✅ Livestreaming Reddit (real-time)
- ✅ Word frequency analysis
- ✅ Wordcloud generation

**Usage:**
```bash
# Scrape subreddit (hot posts, 100 results)
urs -r AskReddit h 100

# Scrape specific user
urs -u spez 50

# Scrape submission comments
urs -c https://www.reddit.com/r/AskReddit/comments/xyz 100

# Livestream subreddit
urs -lr AskReddit

# Generate wordcloud from scraped data
urs -wc scrape_results.json
```

**Rate Limits:** Reddit API: 60 requests/minute (read), 30/minute (write).

**Reliability:** ⭐⭐⭐⭐ Very good. Uses official PRAW library.

---

## 4. Recommended Architecture

### Tier 1: Accountless / No API Key (Priority)

| Platform | Tool | Use Case |
|----------|------|----------|
| YouTube | scrapetube + yt-dlp | All YouTube scraping needs |
| X/Twitter | twikit (burner account) | Light scraping, search |
| Reddit | pushshift (if available) | Historical data only |

### Tier 2: API Key Required (For Reliability)

| Platform | Tool | Use Case |
|----------|------|----------|
| X/Twitter | inference.sh | Heavy scraping, posting, reliability |
| Reddit | URS + PRAW | Full-featured scraping |

### Hybrid Approach (Recommended)

```
┌─────────────────────────────────────────────────────────────┐
│                    Scraping Pipeline                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  YouTube (No credentials)                                   │
│  ├── scrapetube → Channel/playlist/search metadata          │
│  └── yt-dlp → Transcripts, video info                       │
│                                                             │
│  X/Twitter (Choose one)                                     │
│  ├── twikit + burner account → Free, unlimited              │
│  └── inference.sh API key → Reliable, no account risk       │
│                                                             │
│  Reddit (API key required)                                  │
│  └── URS/PRAW → Complete subreddit/redditor access          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Implementation Priority

### Phase 1: YouTube (Immediate)
- ✅ Install: `pip install scrapetube yt-dlp`
- ✅ Test: Channel scraping + transcript download
- ✅ **No credentials needed**

### Phase 2: X/Twitter (Choose path)
- **Path A (Free):** Create burner Twitter account → Install twikit
- **Path B (Reliable):** Sign up for inference.sh → Get API key

### Phase 3: Reddit (If needed)
- Create Reddit app at https://www.reddit.com/prefs/apps
- Install URS: `pip install urs`
- Configure PRAW credentials

---

## 6. Risk Mitigation

### YouTube
- **Risk:** Low. No account = no bans.
- **Mitigation:** Add delays between requests if scraping heavily.

### X/Twitter
- **Risk:** Medium. Account bans possible with twikit.
- **Mitigation:** 
  - Use burner account
  - Rotate accounts if heavy scraping
  - inference.sh eliminates account risk

### Reddit
- **Risk:** Low. Official API usage.
- **Mitigation:** Stay within rate limits (60 req/min).

---

## 7. Environment Setup

Create `~/.openclaw/.scraping.env`:

```bash
# YouTube (no credentials needed)

# X/Twitter - Twikit (optional)
TWITTER_USERNAME=your_burner_username
TWITTER_EMAIL=your_burner_email
TWITTER_PASSWORD=your_burner_password

# X/Twitter - inference.sh (optional)
INFERENCE_API_KEY=your_key_here

# Reddit - PRAW (optional)
REDDIT_CLIENT_ID=your_client_id
REDDIT_CLIENT_SECRET=your_client_secret
REDDIT_USER_AGENT="OpenClawBot/1.0"
```

---

## 8. Quick Start Commands

```bash
# YouTube - Get channel videos
python3 -c "
import scrapetube
videos = scrapetube.get_channel('UCCezIgC97PvUuR4_gbFUs5g')
for v in videos:
    print(f\"{v['videoId']}: {v['title']['runs'][0]['text']}\")
"

# YouTube - Get transcript
yt-dlp --write-auto-sub --skip-download "VIDEO_URL"

# Twitter - Search (twikit)
python3 -c "
import asyncio
from twikit import Client
client = Client('en-US')
# ... (see full example above)
"

# Reddit - Scrape subreddit
urs -r AskReddit h 100
```

---

## 9. Decision Matrix

| If you need... | Use... | Credentials? |
|----------------|--------|--------------|
| YouTube videos + metadata | scrapetube | ❌ None |
| YouTube transcripts | yt-dlp | ❌ None |
| Twitter search (light) | twikit | ✅ Burner account |
| Twitter (heavy/reliable) | inference.sh | ✅ API key |
| Reddit subreddits | URS | ✅ Reddit app |
| Reddit historical | pushshift.io | ❌ None (limited) |

---

## 10. Next Steps

1. **Immediate:** Install YouTube tools (no barriers)
   ```bash
   pip install scrapetube yt-dlp
   ```

2. **Decide on X/Twitter approach:**
   - Option A: I create a burner Twitter account for twikit
   - Option B: You get inference.sh API key

3. **Decide on Reddit:**
   - Create Reddit app for URS (if Reddit scraping needed)

4. **Storage:** Create `~/.openclaw/scraping/` directory for scripts and outputs

---

*Document created: 2026-02-13*
*Strategy: Prioritize accountless, fall back to API keys for reliability*
