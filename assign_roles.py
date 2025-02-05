#!/usr/bin/env python3

import sys
import os

# Manually add local 'python_modules' path to Python's module search path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "python_modules"))

import requests
import json

# Get input data from Terraform
input_data = json.loads(sys.stdin.read())

# Extract required values
user_email = input_data.get("user_email")
role = input_data.get("role")
api_token = input_data.get("api_token")

# Define Okta API details
OKTA_DOMAIN = "trial-2582192.okta.com"
HEADERS = {
    "Authorization": f"SSWS {api_token}",
    "Content-Type": "application/json"
}

# Get User ID from Email
def get_user_id(email):
    url = f"https://{OKTA_DOMAIN}/api/v1/users?q={email}"
    response = requests.get(url, headers=HEADERS)

    if response.status_code == 200 and len(response.json()) > 0:
        return response.json()[0]["id"]
    else:
        print(json.dumps({"error": f"User {email} not found in Okta."}))
        sys.exit(1)

# Assign Role to User
def assign_role(user_id, role_type):
    role_map = {
        "SUPER_ADMIN": "SUPER_ADMIN",
        "APP_ADMIN": "APP_ADMIN",
        "READ_ONLY_ADMIN": "READ_ONLY_ADMIN"
    }

    if role_type not in role_map:
        print(json.dumps({"error": f"Invalid role type: {role_type}"}))
        sys.exit(1)

    role_url = f"https://{OKTA_DOMAIN}/api/v1/users/{user_id}/roles"
    payload = {"type": role_map[role_type]}

    response = requests.post(role_url, headers=HEADERS, json=payload)

    if response.status_code == 204:
        print(json.dumps({"success": f"Assigned {role_type} role to {user_email}"}))
    else:
        print(json.dumps({"error": f"Failed to assign role {role_type} to {user_email}. API Response: {response.text}"}))
        sys.exit(1)

# Execute the Role Assignment
try:
    user_id = get_user_id(user_email)
    assign_role(user_id, role)
except Exception as e:
    print(json.dumps({"error": f"Unexpected error: {str(e)}"}))
    sys.exit(1)
