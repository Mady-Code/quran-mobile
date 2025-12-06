#!/bin/bash
URLS=(
    "https://raw.githubusercontent.com/QuranHub/quran-pages-images/main/Warsh/001.png"
    "https://raw.githubusercontent.com/QuranHub/quran-pages-images/main/warsh/001.jpg"
    "https://raw.githubusercontent.com/QuranHub/quran-pages-images/master/Warsh/001.png"
    "https://raw.githubusercontent.com/QuranHub/quran-pages-images/master/warsh/001.jpg"
    "https://raw.githubusercontent.com/osama-jr/Quran-Images/main/Warsh/001.png"
    "https://raw.githubusercontent.com/osama-jr/Quran-Images/main/warsh/001.png"
    "https://raw.githubusercontent.com/osama-jr/Quran-Images/master/warsh/001.jpg"
)

for url in "${URLS[@]}"; do
    echo "Testing $url"
    status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    echo "Status: $status"
    if [ "$status" -eq 200 ]; then
        echo "FOUND! Working URL: $url"
    fi
done
