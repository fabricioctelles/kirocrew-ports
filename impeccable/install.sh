#!/bin/bash
# Impeccable Port Installer for KiroCrew
# Installs the Impeccable design skill and agent

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIRO_AGENTS="${HOME}/.kiro/agents"
KIRO_CREW="${HOME}/.kiro/crew"
KIRO_SKILLS="${KIRO_CREW}/skills"
KIRO_PROMPTS="${KIRO_CREW}/prompts"
KIRO_CONFIG="${KIRO_CREW}/config.json"

echo "🎨 Installing Impeccable Port for KiroCrew..."
echo ""

# Create directories if they don't exist
mkdir -p "$KIRO_AGENTS"
mkdir -p "$KIRO_SKILLS"
mkdir -p "$KIRO_PROMPTS"

# 1. Install skill (with all scripts)
echo "📦 Installing impeccable skill..."
if [ -d "$KIRO_SKILLS/impeccable" ]; then
    echo "   Removing existing skill..."
    rm -rf "$KIRO_SKILLS/impeccable"
fi
cp -r "$SCRIPT_DIR/skills/impeccable" "$KIRO_SKILLS/"
echo "   ✓ Skill installed to $KIRO_SKILLS/impeccable/"

# 2. Install agent JSON (expand $HOME in prompt path)
echo "📋 Installing impeccable agent..."
sed "s|\$HOME|$HOME|g" "$SCRIPT_DIR/agents/impeccable.json" > "$KIRO_AGENTS/impeccable.json"
echo "   ✓ Agent installed to $KIRO_AGENTS/impeccable.json"

# 3. Install prompt
echo "📝 Installing system prompt..."
cp "$SCRIPT_DIR/prompts/impeccable.md" "$KIRO_PROMPTS/"
echo "   ✓ Prompt installed to $KIRO_PROMPTS/impeccable.md"

# 4. Merge agent binding into config.json
echo "⚙️  Updating config.json..."
if [ -f "$KIRO_CONFIG" ]; then
    # Check if jq is available
    if command -v jq &> /dev/null; then
        # Backup config
        cp "$KIRO_CONFIG" "${KIRO_CONFIG}.bak"
        
        # Read the agent binding from config-fragment.json (with $HOME expanded)
        AGENT_BINDING=$(sed "s|\$HOME|$HOME|g" "$SCRIPT_DIR/config-fragment.json" | jq '.agents.impeccable')
        
        # Merge into existing config
        jq --argjson agent "$AGENT_BINDING" '.agents.impeccable = $agent' "$KIRO_CONFIG" > "${KIRO_CONFIG}.tmp"
        mv "${KIRO_CONFIG}.tmp" "$KIRO_CONFIG"
        echo "   ✓ Agent binding added to config.json"
    else
        echo "   ⚠ jq not found. Please manually add the agent binding from config-fragment.json"
        echo "   to your ~/.kiro/crew/config.json under the 'agents' section."
    fi
else
    echo "   ⚠ config.json not found at $KIRO_CONFIG"
    echo "   Please ensure KiroCrew is installed and run this script again."
fi

echo ""
echo "✅ Impeccable installation complete!"
echo ""
echo "Components installed:"
echo "  • Agent: impeccable (triggers: design review, ui audit, polish, etc.)"
echo "  • Skill: impeccable (23 commands)"
echo "  • Prompt: impeccable.md"
echo ""
echo "Usage:"
echo "  • Ask for a 'design review' or 'ui audit' to auto-route to this agent"
echo "  • Use \$impeccable skill directly for specific commands"
echo "  • Run 'impeccable init' in a project to set up PRODUCT.md and DESIGN.md"
echo ""
echo "📖 See README.md for full documentation"
