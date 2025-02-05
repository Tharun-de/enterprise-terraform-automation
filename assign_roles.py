#!/usr/bin/env python3

import requests
import json
import sys
import os

# Okta API Configuration
OKTA_DOMAIN = "https://trial-2582192.okta.com"
OKTA_API_TOKEN = os.getenv("OKTA_API_TOKEN")  # Use environment variable for security

HEADERS = {
    "Authorization": f"SSWS {OKTA_API_TOKEN}",
    "Accept": "application/json",
    "Content-Type": "application/json"
}

def assign_role(email, role):
    """Assigns a role to a user in Okta"""
    try:
        # Get user ID
        response = requests.get(f"{OKTA_DOMAIN}/api/v1/users?q={email}", headers=HEADERS)
        response.raise_for_status()
        user_data = response.json()

        if not user_data:
            return {"error": f"User {email} not found in Okta"}

        user_id = user_data[0]['id']

        # Assign Role
        role_map = {
            "Admin Group": "ORG_ADMIN",
            "App Admin Group": "APP_ADMIN",
            "Standard Users": "USER"
        }

        if role not in role_map:
            return {"error": f"Invalid role: {role}"}

        role_payload = {
            "type": role_map[role]
        }

        role_url = f"{OKTA_DOMAIN}/api/v1/users/{user_id}/roles"
        role_response = requests.post(role_url, headers=HEADERS, json=role_payload)

        if role_response.status_code == 204:
            return {"success": f"Role {role} assigned to {email}"}
        else:
            return {"error": f"Failed to assign role {role} to {email}. Response: {role_response.text}"}

    except requests.exceptions.RequestException as e:
        return {"error": f"API Request failed: {str(e)}"}

if __name__ == "__main__":
    input_data = json.load(sys.stdin)
    email = input_data.get("email")
    role = input_data.get("role")

    if not email or not role:
        print(json.dumps({"error": "Missing email or role"}))
        sys.exit(1)

    result = assign_role(email, role)
    print(json.dumps(result))
