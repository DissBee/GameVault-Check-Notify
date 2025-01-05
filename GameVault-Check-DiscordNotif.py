import os
import subprocess
import json

# Variables
SSH_HOST = "user@address"  # Update with your SSH host info
SSH_PORT = 22   # Default to 22
CURRENT_LIST_PATH = "./currentlist.txt"  # Where the current list will be kept
GAMES_PATH = "/path/to/games/directory"  # Update with the path to your games directory
DISCORD_HOOK_URL = "yourURLgoeshere"
DISCORD_ROLE_ID = "<@roleidnumber>"  # Update with your Discord role ID
LOCAL_RUN = False  # Set to True to run locally instead of SSHing into a remote system - no i will not add this to the bash script do it yourself lol

def send_discord_message(content):
    # Create the JSON payload
    payload = {
        "content": content
    }

    # Verify payload before sending if needed (uncomment these lines for debugging)
    # print("Payload:", json.dumps(payload))
    # input("Press Enter to confirm or quit now.")

    payload_str = json.dumps(payload)

    # Split and send if the message exceeds 2000 characters
    if len(payload_str) > 2000:
        print("Message is too long; splitting into two parts.")
        part1 = payload_str[:2000]
        part2 = payload_str[2000:]

        subprocess.run(["curl", "-H", "Content-Type: application/json", "-d", part1, DISCORD_HOOK_URL])
        subprocess.run(["curl", "-H", "Content-Type: application/json", "-d", part2, DISCORD_HOOK_URL])
    else:
        subprocess.run(["curl", "-H", "Content-Type: application/json", "-d", payload_str, DISCORD_HOOK_URL])

def run_command(command):
    # Run shell command
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    return result.stdout.strip()

def get_games_list():
    # Get games list
    if LOCAL_RUN:
        return run_command(f"cd '{GAMES_PATH}' && ls -1")
    else:
        return run_command(f"ssh -p {SSH_PORT} {SSH_HOST} \"cd '{GAMES_PATH}' && ls -1\"")

def main():
    # Check if currentlist.txt exists
    if not os.path.isfile(CURRENT_LIST_PATH) or os.path.getsize(CURRENT_LIST_PATH) == 0:
        print("currentlist.txt is empty or missing. Grabbing the initial games list.")
        games_list = get_games_list()
        with open(CURRENT_LIST_PATH, "w") as file:
            file.write(games_list)
        print("Games list grabbed - next run will look for changes.")
        return

    # Grab the new list of games
    NEW_LIST_PATH = "./newlist.txt"
    new_games_list = get_games_list()
    with open(NEW_LIST_PATH, "w") as file:
        file.write(new_games_list)

    # Compare currentlist.txt and newlist.txt
    with open(CURRENT_LIST_PATH, "r") as file:
        current_list = file.read().splitlines()
    with open(NEW_LIST_PATH, "r") as file:
        new_list = file.read().splitlines()

    difference_new = sorted(set(new_list) - set(current_list))
    difference_removed = sorted(set(current_list) - set(new_list))

    # Prepare the message starting with the @
    message = DISCORD_ROLE_ID

    if difference_new:
        message += "\nNew Games Added:\n" + "\n".join(difference_new)

    if difference_removed:
        message += "\nGames Removed:\n" + "\n".join(difference_removed)

    # If there are differences, send the message
    if difference_new or difference_removed:
        send_discord_message(message)
        os.replace(NEW_LIST_PATH, CURRENT_LIST_PATH)
    else:
        print("No changes detected.")

    print("Script execution completed.")

if __name__ == "__main__":
    main()
