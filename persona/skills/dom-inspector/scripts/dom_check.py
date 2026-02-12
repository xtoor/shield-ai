import os
import sys
from bs4 import BeautifulSoup

def inspect_dom(file_path):
    if not os.path.exists(file_path):
        print(f"Error: File {file_path} not found.")
        return

    with open(file_path, 'r', encoding='utf-8') as f:
        html_content = f.read()

    soup = BeautifulSoup(html_content, 'html.parser')
    errors = []

    # 1. Check for duplicate IDs
    ids = [tag['id'] for tag in soup.find_all(id=True)]
    duplicate_ids = set([x for x in ids if ids.count(x) > 1])
    if duplicate_ids:
        errors.append(f"CRITICAL: Duplicate IDs found: {', '.join(duplicate_ids)}")

    # 2. Check for missing critical tags
    if not soup.find('head'): errors.append("WARN: Missing <head> tag.")
    if not soup.find('body'): errors.append("WARN: Missing <body> tag.")
    if not soup.find('title'): errors.append("INFO: Missing <title> tag.")

    # 3. Check for broken local assets (relative only)
    # This is basic, just checks if they are defined
    for img in soup.find_all('img'):
        if not img.get('src'):
            errors.append(f"WARN: <img> tag found with missing src.")

    # 4. Check for unclosed script/style blocks (BS4 handles this but let's check content)
    # Placeholder for more complex regex checks

    # 5. Accessibility basics
    for img in soup.find_all('img'):
        if not img.get('alt'):
            errors.append(f"A11Y: <img> at line {img.sourceline} missing alt attribute.")

    if not errors:
        print("SUCCESS: No structural DOM errors detected.")
    else:
        print("\n".join(errors))

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python dom_check.py <path_to_html>")
    else:
        inspect_dom(sys.argv[1])
