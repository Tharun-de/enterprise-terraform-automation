import csv
import json
import sys

csv_file = "users.csv"

try:
    with open(csv_file, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        users = [row for row in reader]
        print(json.dumps({"users": users}))
except Exception as e:
    print(json.dumps({"error": str(e)}))
    sys.exit(1)
