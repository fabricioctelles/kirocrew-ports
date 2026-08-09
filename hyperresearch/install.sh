#!/bin/bash
# HyperResearch Port - Installation Script
# Installs skills, agent, prompt, and updates config.json

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$HOME/.kiro/crew/skills"
AGENTS_DIR="$HOME/.kiro/agents"
PROMPTS_DIR="$HOME/.kiro/crew/prompts"
CONFIG_FILE="$HOME/.kiro/crew/config.json"

echo "🔬 HyperResearch Port Installer"
echo "================================"
echo ""

# Check if KiroCrew is set up
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ KiroCrew not found at $CONFIG_FILE"
    echo "   Run 'kirocrew gateway' first to initialize KiroCrew."
    exit 1
fi

# Create directories if needed
mkdir -p "$SKILLS_DIR"
mkdir -p "$AGENTS_DIR"
mkdir -p "$PROMPTS_DIR"

# Install skills
echo "📦 Installing skills to $SKILLS_DIR..."
for skill_dir in "$SCRIPT_DIR/skills/"*/; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        cp -r "$skill_dir" "$SKILLS_DIR/"
        echo "   ✓ $skill_name"
    fi
done

# Install agent
echo "📦 Installing agent to $AGENTS_DIR..."
for agent in "$SCRIPT_DIR/agents/"*.json; do
    if [ -f "$agent" ]; then
        filename=$(basename "$agent")
        sed "s|\$HOME|$HOME|g" "$agent" > "$AGENTS_DIR/$filename"
        echo "   ✓ $filename"
    fi
done

# Install prompt
echo "📝 Installing prompt to $PROMPTS_DIR..."
for prompt in "$SCRIPT_DIR/prompts/"*.md; do
    if [ -f "$prompt" ]; then
        cp "$prompt" "$PROMPTS_DIR/"
        echo "   ✓ $(basename "$prompt")"
    fi
done

# Merge agent bindings into config.json
echo "⚙️  Updating config.json with agent binding..."

python3 -c "
import json, os

config_file = os.path.expanduser('~/.kiro/crew/config.json')
fragment_file = '$SCRIPT_DIR/config-fragment.json'

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
echo "Installed:"
echo "  • 18 hyr-* skills"
echo "  • hyperresearch agent"
echo ""
echo "Usage:"
echo "  1. Restart KiroCrew gateway"
echo "  2. Switch to 'hyperresearch' agent in dashboard"
echo "  3. Or use: !agent hyperresearch"
