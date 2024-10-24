#!/bin/sh

# Define the path to the game binary (relative path since it's in the same folder)
GAME_BINARY="/app/bin/com.github.elliegames.sanctify-game.x86_64"

# Check if the game binary exists
if [ -f "$GAME_BINARY" ]; then
  # Run the game
  "$GAME_BINARY" --main-pack /app/share/com.github.elliegames.sanctify-game/sanctify.pck
else
  echo "Error: Game binary not found in the current directory."
  exit 1
fi
