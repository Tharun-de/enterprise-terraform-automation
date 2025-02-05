import csv
import json
import sys

csv_file = "users.csv"

try:
    with open(csv_file, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        users = {user["email"]: user for user in reader}  # Convert list to dictionary

    print(json.dumps({"users": users}))  # Return a JSON object with string keys
except Exception as e:
    print(json.dumps({"error": str(e)}))
    sys.exit(1)
