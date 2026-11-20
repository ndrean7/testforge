#!/bin/sh
# testforge-init: scaffold a clean test workspace for a target codebase.
# Usage: sh scripts/testforge-init.sh /path/to/repo-copy <name> [solidity|js]
# Creates ./testforge-workspaces/<name>/ with a starter layout and a
# copy of the target's source files. Never touches the original repo.
set -eu

TARGET="${1:-}"
NAME="${2:-}"
STACK="${3:-solidity}"

if [ -z "$TARGET" ] || [ -z "$NAME" ]; then
  echo "usage: sh scripts/testforge-init.sh /path/to/repo-copy <name> [solidity|js]"
  exit 1
fi

if [ ! -d "$TARGET" ]; then
  echo "error: target directory not found: $TARGET"
  exit 1
fi

ROOT="$(pwd)/testforge-workspaces/$NAME"
if [ -e "$ROOT" ]; then
  echo "error: workspace already exists: $ROOT"
  echo "pick another name or remove it first."
  exit 1
fi

mkdir -p "$ROOT/src" "$ROOT/test"

# Copy the target's source files (Solidity or JS/TS) into src/.
case "$STACK" in
  solidity)
    for d in src contracts; do
      if [ -d "$TARGET/$d" ]; then
        cp -r "$TARGET/$d"/. "$ROOT/src/" 2>/dev/null || true
      fi
    done
    cat > "$ROOT/foundry.toml" <<'EOF'
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc = "0.8.20"
EOF
    cp "$(dirname "$0")/../reference/foundry-test-template.t.sol" "$ROOT/test/Target.t.sol"
    echo "Solidity workspace ready: $ROOT"
    echo "Next: cd $ROOT && forge install foundry-rs/forge-std && forge test"
    ;;
  js)
    for d in src lib; do
      if [ -d "$TARGET/$d" ]; then
        cp -r "$TARGET/$d"/. "$ROOT/src/" 2>/dev/null || true
      fi
    done
    cat > "$ROOT/package.json" <<'EOF'
{
  "name": "testforge-workspace",
  "private": true,
  "type": "module",
  "scripts": {
    "test": "node --test"
  }
}
EOF
    cp "$(dirname "$0")/../reference/js-test-template.test.mjs" "$ROOT/test/target.test.mjs"
    echo "JavaScript workspace ready: $ROOT"
    echo "Next: cd $ROOT && npm test"
    ;;
  *)
    echo "error: stack must be solidity or js, got: $STACK"
    exit 1
    ;;
esac

echo "Source copied from: $TARGET"
echo "Templates are starting points — replace Target with the real contract or module."
