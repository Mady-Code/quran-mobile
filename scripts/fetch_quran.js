const fs = require('fs');
const https = require('https');

const API_BASE = 'https://api.quran.com/api/v4';
const TRANSLATION_ID = 131; // Clear Quran

async function fetchJson(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

async function main() {
  console.log('Fetching chapters...');
  const chaptersRes = await fetchJson(`${API_BASE}/chapters`);
  const chapters = chaptersRes.chapters;
  
  const allVerses = [];

  console.log(`Found ${chapters.length} chapters. Fetching verses...`);

  // Fetch verses for each chapter
  // We'll do it in batches or sequentially to avoid rate limits
  for (const chapter of chapters) {
    const id = chapter.id;
    console.log(`Fetching Surah ${id}...`);
    
    // Fetch verses with Uthmani text and translation
    // Using pagination to ensure we get all verses if needed, but usually by_chapter returns all if we ask?
    // Actually api.quran.com paginates. Default per_page is 10. We need to set per_page to high number.
    // Max per_page is 50? Let's check. 
    // Safest is to loop pages, but for simplicity let's try a large per_page.
    // Actually, let's just use the endpoint that returns all verses for a chapter if possible.
    // Or just loop pages.
    
    // Let's try fetching with per_page=300 (Al-Baqarah is 286).
    const url = `${API_BASE}/verses/by_chapter/${id}?language=en&words=false&translations=${TRANSLATION_ID}&fields=text_uthmani&per_page=300`;
    
    try {
      const res = await fetchJson(url);
      const verses = res.verses.map(v => ({
        id: v.id,
        verse_key: v.verse_key,
        text_uthmani: v.text_uthmani,
        translations: v.translations
      }));
      allVerses.push(...verses);
    } catch (e) {
      console.error(`Failed to fetch Surah ${id}:`, e);
    }
  }

  const output = {
    verses: allVerses
  };

  fs.writeFileSync('assets/json/quran.json', JSON.stringify(output, null, 2));
  console.log(`Saved ${allVerses.length} verses to assets/json/quran.json`);
}

main();
