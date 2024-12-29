#!/bin/bash

# Variables
SSH_HOST="user@address"  # Update with your SSH host info
SSH_PORT=22   # Default to 22
CURRENT_LIST_PATH="./currentlist.txt" # Where the current list will be kept - move this wherever you want but keep name the same
GAMES_PATH="/your/games/directory"  # Update with the path to your games directory
DISCORD_HOOK_URL="your hook url goes here>"
DISCORD_ROLE_ID="<@roleidnumber>"   # Update with your Discord role ID

# Function to send Discord webhook message
send_discord_message() {
  local content="$1"

  # Escape special characters for JSON (quotes, backslashes, and newlines) - seems to be needed for this to work properly
  content=$(printf "%s" "$content" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')

  # Create the JSON payload using a here string to make the multi-line nature not stupid
  local payload=$(cat <<EOF
{
  "content": "$content"
}
EOF
)

  # Verify payload before sending - if you want - uncomment these two lines:
  #echo "Payload: $content"
  #read -p "press anything to confirm or quit now"

  # Split and send if the message exceeds 2000 characters
  if [ ${#payload} -gt 2000 ]; then
    echo "Message is too long; splitting into two parts."

    # Split the content into two parts
    local part1=$(echo "$payload" | head -c 2000)
    local part2=$(echo "$payload" | tail -c +2001)

    # Send the parts
    curl -H "Content-Type: application/json" -d "$part1" "$DISCORD_HOOK_URL"
    curl -H "Content-Type: application/json" -d "$part2" "$DISCORD_HOOK_URL"
  else
    # Send the full payload if it's within the limit
    curl -H "Content-Type: application/json" -d "$payload" "$DISCORD_HOOK_URL"
  fi
}

# Check if currentlist.txt exists - if not then create it.
if [ ! -s "$CURRENT_LIST_PATH" ]; then
  echo "currentlist.txt is empty or missing. Grabbing the initial games list."
  ssh -p "$SSH_PORT" "$SSH_HOST" "cd '$GAMES_PATH' && ls -1 | sed 's|^\./||'" > "$CURRENT_LIST_PATH"
  echo "Games list grabbed - next run will look for changes."
  exit 0
fi

# Grab the new list of games from remote host
NEW_LIST_PATH="./newlist.txt"
ssh -p "$SSH_PORT" "$SSH_HOST" "cd '$GAMES_PATH' && ls -1 | sed 's|^\./||'" > "$NEW_LIST_PATH"

# Compare currentlist.txt and newlist.txt
difference_new=$(comm -13 <(sort "$CURRENT_LIST_PATH") <(sort "$NEW_LIST_PATH"))
difference_removed=$(comm -23 <(sort "$CURRENT_LIST_PATH") <(sort "$NEW_LIST_PATH"))

# Prepare the message starting with the @
message="$DISCORD_ROLE_ID"

# Check for new games and prepare message
if [ -n "$difference_new" ]; then
  message+="\nNew Games Added:\n$difference_new\n"
fi

# Check for removed games and prepare message
if [ -n "$difference_removed" ]; then
  message+="\nGames Removed:\n$difference_removed\n"
fi

# If there are differences, send the message
if [ -n "$difference_new" ] || [ -n "$difference_removed" ]; then
  message=$(echo -e "$message")
  send_discord_message "$message"
  cp "$NEW_LIST_PATH" "$CURRENT_LIST_PATH"
  rm "$NEW_LIST_PATH"
else
  echo "No changes detected."
fi

# END
echo "Script execution completed."
