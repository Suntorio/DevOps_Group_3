import requests
from bs4 import BeautifulSoup
import json

# URL of the idioms page
url = "https://storylearning.com/blog/english-idioms"

# Send HTTP request
response = requests.get(url)
response.raise_for_status()

# Parse the HTML
soup = BeautifulSoup(response.text, "html.parser")

idioms = []

# Heuristic: idioms are mostly in <h3> tags with a <p> explanation right after
for h3 in soup.find_all("h3"):
    phrase = h3.get_text(strip=True)
    p = h3.find_next_sibling("p")
    meaning = p.get_text(strip=True) if p else ""

    # Filter out ads or irrelevant lines
    if phrase and meaning and len(phrase.split()) < 10:
        idioms.append({
            "phrase": phrase,
            "meaning": meaning
        })

print(f"Extracted {len(idioms)} idioms")

# Save to idioms.json
with open("idioms.json", "w", encoding="utf-8") as f:
    json.dump(idioms, f, indent=2, ensure_ascii=False)

print("Done! Check idioms.json")