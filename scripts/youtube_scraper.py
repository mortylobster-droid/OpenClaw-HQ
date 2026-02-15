#!/usr/bin/env python3
"""
YouTube Scraping Helper for OpenClaw HQ
Uses: scrapetube + yt-dlp
No API key or account required
"""

import sys
import subprocess
import re
from pathlib import Path

def get_channel_videos(channel_id, limit=None):
    """Get videos from a YouTube channel."""
    import scrapetube
    
    videos = scrapetube.get_channel(channel_id, limit=limit)
    results = []
    for video in videos:
        results.append({
            'id': video['videoId'],
            'title': video['title']['runs'][0]['text'],
            'url': f"https://youtube.com/watch?v={video['videoId']}"
        })
    return results

def get_playlist_videos(playlist_id, limit=None):
    """Get videos from a YouTube playlist."""
    import scrapetube
    
    videos = scrapetube.get_playlist(playlist_id, limit=limit)
    results = []
    for video in videos:
        results.append({
            'id': video['videoId'],
            'title': video['title']['runs'][0]['text'],
            'url': f"https://youtube.com/watch?v={video['videoId']}"
        })
    return results

def search_videos(query, limit=10):
    """Search YouTube for videos."""
    import scrapetube
    
    videos = scrapetube.get_search(query, limit=limit)
    results = []
    for video in videos:
        results.append({
            'id': video['videoId'],
            'title': video['title']['runs'][0]['text'],
            'url': f"https://youtube.com/watch?v={video['videoId']}"
        })
    return results

def get_transcript(video_url, output_file=None):
    """Download transcript from a YouTube video."""
    import os
    
    # Use yt-dlp to get auto-generated subtitles
    cmd = [
        'yt-dlp',
        '--write-auto-sub',
        '--skip-download',
        '--output', 'transcript_temp',
        video_url
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode != 0:
        print(f"Error: {result.stderr}")
        return None
    
    # Find the generated VTT file
    vtt_files = list(Path('.').glob('transcript_temp*.vtt'))
    if not vtt_files:
        print("No transcript available for this video")
        return None
    
    vtt_file = vtt_files[0]
    
    # Convert to clean text
    text_content = []
    seen = set()
    
    with open(vtt_file, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            # Skip metadata lines
            if not line or line.startswith('WEBVTT') or line.startswith('Kind:') or \
               line.startswith('Language:') or '-->' in line:
                continue
            # Remove HTML tags
            clean = re.sub(r'<[^>]+>', '', line)
            # Unescape HTML entities
            clean = clean.replace('&amp;', '&').replace('&lt;', '<').replace('&gt;', '>')
            if clean and clean not in seen:
                text_content.append(clean)
                seen.add(clean)
    
    # Clean up VTT file
    vtt_file.unlink()
    
    transcript = '\n'.join(text_content)
    
    if output_file:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(transcript)
        print(f"Transcript saved to: {output_file}")
    
    return transcript

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage:")
        print(f"  {sys.argv[0]} channel <channel_id> [limit]")
        print(f"  {sys.argv[0]} playlist <playlist_id> [limit]")
        print(f"  {sys.argv[0]} search <query> [limit]")
        print(f"  {sys.argv[0]} transcript <video_url> [output_file]")
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == 'channel':
        channel_id = sys.argv[2]
        limit = int(sys.argv[3]) if len(sys.argv) > 3 else None
        videos = get_channel_videos(channel_id, limit)
        for v in videos:
            print(f"{v['id']}: {v['title']}")
    
    elif command == 'playlist':
        playlist_id = sys.argv[3]
        limit = int(sys.argv[3]) if len(sys.argv) > 3 else None
        videos = get_playlist_videos(playlist_id, limit)
        for v in videos:
            print(f"{v['id']}: {v['title']}")
    
    elif command == 'search':
        query = sys.argv[2]
        limit = int(sys.argv[3]) if len(sys.argv) > 3 else 10
        videos = search_videos(query, limit)
        for v in videos:
            print(f"{v['id']}: {v['title']}")
    
    elif command == 'transcript':
        url = sys.argv[2]
        output = sys.argv[3] if len(sys.argv) > 3 else None
        transcript = get_transcript(url, output)
        if transcript and not output:
            print(transcript)
    
    else:
        print(f"Unknown command: {command}")
