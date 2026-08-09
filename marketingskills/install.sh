#!/bin/bash
# MarketingSkills Port - Installation Script
# Installs agents, prompts, and updates config.json with agent bindings

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$HOME/.kiro/agents"
PROMPTS_DIR="$HOME/.kiro/crew/prompts"
CONFIG_FILE="$HOME/.kiro/crew/config.json"

echo "🚀 MarketingSkills Port Installer"
echo "================================="
echo ""

# Check if KiroCrew is set up
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ KiroCrew not found at $CONFIG_FILE"
    echo "   Run 'kirocrew gateway' first to initialize KiroCrew."
    exit 1
fi

# Create directories if needed
mkdir -p "$AGENTS_DIR"
mkdir -p "$PROMPTS_DIR"

# Install agents
echo "📦 Installing agent definitions to $AGENTS_DIR..."
for agent in "$SCRIPT_DIR/agents/"*.json; do
    if [ -f "$agent" ]; then
        # Replace $HOME with actual path in the file
        filename=$(basename "$agent")
        sed "s|\$HOME|$HOME|g" "$agent" > "$AGENTS_DIR/$filename"
        echo "   ✓ $(basename "$agent")"
    fi
done

# Install prompts
echo "📝 Installing prompts to $PROMPTS_DIR..."
for prompt in "$SCRIPT_DIR/prompts/"*.md; do
    if [ -f "$prompt" ]; then
        cp "$prompt" "$PROMPTS_DIR/"
        echo "   ✓ $(basename "$prompt")"
    fi
done

# Merge agent bindings into config.json
echo "⚙️  Updating config.json with agent bindings..."

# Use Python for safe JSON merging
python3 << 'EOF'
import json
import sys
import os

config_file = os.path.expanduser("~/.kiro/crew/config.json")
fragment_file = os.path.join(os.environ.get("SCRIPT_DIR", "."), "config-fragment.json")

# If SCRIPT_DIR not in env, use the directory containing this script
if not os.path.exists(fragment_file):
    script_dir = os.path.dirname(os.path.abspath(__file__)) if "__file__" in dir() else "."
    fragment_file = os.path.join(script_dir, "config-fragment.json")

# Read current config
try:
    with open(config_file, "r") as f:
        config = json.load(f)
except Exception as e:
    print(f"   ❌ Failed to read config.json: {e}")
    sys.exit(1)

# Read fragment
fragment_path = sys.argv[1] if len(sys.argv) > 1 else fragment_file
try:
    with open(fragment_path, "r") as f:
        fragment = json.load(f)
except Exception as e:
    print(f"   ❌ Failed to read config-fragment.json: {e}")
    sys.exit(1)

# Ensure agents section exists
if "agents" not in config:
    config["agents"] = {}

# Merge agent bindings
new_agents = fragment.get("agents", {})
added = 0
updated = 0
for name, binding in new_agents.items():
    if name in config["agents"]:
        config["agents"][name] = binding
        updated += 1
    else:
        config["agents"][name] = binding
        added += 1

# Write updated config
try:
    with open(config_file, "w") as f:
        json.dump(config, f, indent=2)
except Exception as e:
    print(f"   ❌ Failed to write config.json: {e}")
    sys.exit(1)

print(f"   ✓ Added {added} new agents, updated {updated} existing")
EOF

# Pass the fragment path
SCRIPT_DIR="$SCRIPT_DIR" python3 -c "
import json, os, sys

config_file = os.path.expanduser('~/.kiro/crew/config.json')
fragment_file = os.path.join('$SCRIPT_DIR', 'config-fragment.json')

with open(config_file, 'r') as f:
    config = json.load(f)

with open(fragment_file, 'r') as f:
    fragment = json.load(f)

if 'agents' not in config:
    config['agents'] = {}

added = updated = 0
for name, binding in fragment.get('agents', {}).items():
    if name in config['agents']:
        updated += 1
    else:
        added += 1
    config['agents'][name] = binding

with open(config_file, 'w') as f:
    json.dump(config, f, indent=2)

print(f'   ✓ Added {added} new agents, updated {updated} existing')
"

echo ""
echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Restart KiroCrew gateway to pick up changes"
echo "  2. Use the agent selector to switch to 'marketingcrew'"
echo "  3. Or in Slack: !agent marketingcrew"
echo ""
echo "Installed agents:"
echo "  • marketingcrew (orchestrator)"
echo "  • mkt-seo, mkt-cro, mkt-copy, mkt-paid"
echo "  • mkt-growth, mkt-sales, mkt-strategy, mkt-council"
