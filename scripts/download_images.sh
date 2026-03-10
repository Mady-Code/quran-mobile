#!/bin/bash

# Base directories
BASE_DIR="assets/images/quran"
HAFS_DIR="$BASE_DIR/hafs"
WARSH_DIR="$BASE_DIR/warsh"

# Create directories
mkdir -p "$HAFS_DIR"
mkdir -p "$WARSH_DIR"

echo "Created directories: $HAFS_DIR, $WARSH_DIR"

# Download Hafs (Madinah)
# Source: Android Quran Data (Reliable mirror)
echo "Downloading Hafs (Madinah) images..."
for i in {1..604}
do
   # Pad with zeros (e.g. 001, 010, 100)
   PADDED_NUM=$(printf "%03d" $i)
   FILE_PATH="$HAFS_DIR/$i.png"
   
   # Check if file exists and is essentially empty (HTML error page)
   if [ -f "$FILE_PATH" ]; then
       SIZE=$(stat -f%z "$FILE_PATH")
       if [ "$SIZE" -lt 1000 ]; then
           echo "Page $i (Hafs) seems corrupted (size $SIZE bytes). Redownloading..."
           rm "$FILE_PATH"
       else
           echo "Page $i (Hafs) already exists, skipping."
           continue
       fi
   fi

   echo "Downloading Hafs Page $PADDED_NUM..."
   # Using -L to follow redirects (301)
   curl -s -L "https://api2.mushafmakkah.com/files/masahef/webNewMadina/png/$PADDED_NUM.png" -o "$FILE_PATH"
   # curl -s -L "http://android.quran.com/data/width_1024/page$PADDED_NUM.png" -o "$FILE_PATH"
done

# Warsh download skipped as per user request (no reliable source found)
# To enable Warsh, add a valid source URL here.

echo "Download process complete. Please verify the contents of $BASE_DIR."
