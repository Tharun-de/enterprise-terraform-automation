import subprocess
import sys
import json
import requests

# Ensure correct urllib3 and requests versions
try:
    import urllib3
    # Check if urllib3 is the correct version
    if urllib3.__version__ != "1.26.16":
        raise ImportError("Incorrect urllib3 version detected")
except ImportError:
    print("Installing correct urllib3 and requests versions...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "urllib3==1.26.16", "requests==2.26.0"])
    import requests  # Import again after installation
    import urllib3

# Disable SSL warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Okta API Details
OKTA_DOMAIN = "https://trial-2582192.okta.com"
OKTA_API_TOKEN = "001sAoRTIR_jh_GAwDeZd21YN2sl50JJhPodU60Qbo"

HEADERS = {
    "Authorization": f"SSWS {OKTA_API_TOKEN}",
    "Content-Type": "application/json",
    "Accept": "application/json",
}

# Read input from Terraform
def read_input():
    try:
        input_data = json.load(sys.stdin)
        return input_data
    except json.JSONDecodeError as e:
        print(f"Error reading input JSON: {e}")
        sys.exit(1)

# Assign role to user in Okta
def assign_role(user_email, role_type):
    user_search_url = f"{OKTA_DOMAIN}/api/v1/users/{user_email}"
    response = requests.get(user_search_url, headers=HEADERS, verify=False)

    if response.status_code == 200:
        user_id = response.json()["id"]
        assign_role_url = f"{OKTA_DOMAIN}/api/v1/users/{user_id}/roles"
        role_payload = {"type": role_type}

        role_response = requests.post(assign_role_url, headers=HEADERS, json=role_payload, verify=False)

        if role_response.status_code == 200 or role_response.status_code == 201:
            return {"status": "success", "message": f"Role {role_type} assigned to {user_email}"}
        else:
            return {"status": "error", "message": f"Failed to assign role {role_type}: {role_response.text}"}
    else:
        return {"status": "error", "message": f"User not found: {user_email}"}

# Main function to process Terraform input
if __name__ == "__main__":
    input_data = read_input()
    user_email = input_data.get("user_email")
    role_type = input_data.get("role_type", "APP_ADMIN")  # Default to APP_ADMIN if not provided

    result = assign_role(user_email, role_type)

    # Output result in Terraform expected format
    print(json.dumps(result))
