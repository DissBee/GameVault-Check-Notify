#!/bin/bash

# Variables
SCRIPT_DIRECTORY="/scripts/GameVault-Check-Notify" #Set this to the path where you want the script to save the files it creates
CURRENT_LIST_PATH="$SCRIPT_DIRECTORY/currentlist.txt" # Dont change this unless you know what you are doing
NEW_LIST_PATH="$SCRIPT_DIRECTORY/newlist.txt" # Dont change this unless you know what you are doing
GAMES_PATH="/your/games/directory"  # Update with the path to your games directory (your mount point to the games if they are hosted on another system) 
# games path might be something like '/run/user/1000/gvfs/smb-share:server=IPaddresshere,share=blahblah' which you would need to use if this applies to you idk
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
  cd "$GAMES_PATH"
  if ! ls -1 | sed 's|^\./||' > "$CURRENT_LIST_PATH"; then
    echo "Error: Failed to process games list" >&2
    exit 1
  fi
  echo "Games list grabbed - next run will look for changes."
  exit 0
fi

# Grab the new list of games from remote host
cd "$GAMES_PATH" 
if ! ls -1 | sed 's|^\./||' > "$NEW_LIST_PATH"; then
  echo "Error: Failed to process games list" >&2
  exit 1
fi
echo "Grabbed updated games list - looking for changes"

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
