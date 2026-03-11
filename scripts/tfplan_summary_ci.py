import json
import sys

PLAN_PATH = "../infra/tfplan.json"

try:
    with open(PLAN_PATH) as f:
        plan = json.load(f)
except FileNotFoundError:
    print(f"ERROR: {PLAN_PATH} not found")
    sys.exit(1)
except json.JSONDecodeError as e:
    print(f"ERROR: Invalid JSON in plan file: {e}")
    sys.exit(1)

creates, updates, replaces, deletes = [], [], [], []

for rc in plan.get("resource_changes", []):
    actions = rc["change"]["actions"]

    # Include module path if present
    module = rc.get("module_address", "")
    resource = f'{module}.{rc["type"]}.{rc["name"]}' if module else f'{rc["type"]}.{rc["name"]}'

    if actions in (["no-op"], ["read"]):
        continue

    if actions == ["create"]:
        creates.append(resource)
    elif actions == ["delete"]:
        deletes.append(resource)
    elif actions == ["update"]:
        updates.append(resource)
    elif "create" in actions and "delete" in actions:
        replaces.append(resource)

print("\nTerraform Plan Summary\n")

if not any([creates, updates, replaces, deletes]):
    print("No changes. Infrastructure is up-to-date.")
else:
    for r in creates:
        print(f"  + {r}")
    for r in updates:
        print(f"  ~ {r}")
    for r in replaces:
        print(f"  -/+ {r}")
    for r in deletes:
        print(f"  - {r}")

print(f"\nPlan: {len(creates)} to add, {len(updates)} to change, {len(replaces)} to replace, {len(deletes)} to destroy.")
