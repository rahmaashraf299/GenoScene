import requests

url = "https://naida-pterodactylous-chillingly.ngrok-free.dev/admin/"
file_path = "test_upload.csv"

try:
    print(f"Checking {url}...")
    headers = {"ngrok-skip-browser-warning": "69420"}
    response = requests.get(url, headers=headers)
        
    print(f"Status Code: {response.status_code}")
    # Print first 200 chars to avoid flooding
    print(f"Response Body Preview: {response.text[:200]}")
except Exception as e:
    print(f"Error: {e}")
