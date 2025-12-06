#!/bin/bash
URLS=(
    "http://android.quran.com/data/1024/warsh/page001.png"
    "http://android.quran.com/data/1260/warsh/page001.png"
    "http://android.quran.com/data/width_1024/warsh/page001.png"
    "http://android.quran.com/data/width_1260/warsh/page001.png"
    "https://android.quran.com/data/1024/warsh/page001.png"
)

for url in "${URLS[@]}"; do
    echo "Testing $url"
    status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    echo "Status: $status"
    if [ "$status" -eq 200 ]; then
        echo "FOUND! Working URL: $url"
    fi
done
