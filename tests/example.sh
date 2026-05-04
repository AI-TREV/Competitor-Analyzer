#!/usr/bin/env bash
set -e

echo "Test 1: has title"
agent-browser open https://playwright.dev/
TITLE=$(agent-browser get text title)
echo "$TITLE" | grep -qi "playwright" || { echo "FAIL: title did not contain 'Playwright'"; exit 1; }
echo "PASS"

echo "Test 2: get started link"
agent-browser open https://playwright.dev/
agent-browser find role link click --name "Get started"
agent-browser find role heading --name "Installation" || { echo "FAIL: Installation heading not found"; exit 1; }
echo "PASS"

agent-browser close
echo "All tests passed."
