# GameVault-Check-Notify
A collection of scripts that are all the same thing but different languages. Check your GameVault "Games" directory and send a Discord webhook message with the changes (games added or removed)

I'll get around to cleaning up this readme eventually. 

These are low-effort scripts - I tested that they work enough - use at your own risk and change for your environment as needed


# NEW - Python version that also checks if it is run locally on the same system that hosts the games - yay!
New variable: LOCAL_RUN bool 

Now we have python too - neato!


# NEWish - Bash script that does this too but assumes you know what you are doing. Assumes games are on remote host.
Variables:

* SSH_Host="user@address" (set this to be the user@IP/name of the host that holds your games)
* SSH_Port=22 (change this if you use a different port)
* CURRENT_LIST_PATH="./currentlist.txt" (change this if you want)
* GAMES_PATH="/your/path/to/games/directory/on/remote/host"
* DISCORD_HOOK_URL="your hook url goes here"
* DISCORD_ROLE_ID="put your role id to @ here in the proper format"


# Everything below this point is for the powershell version

# Notes
This is a very basic script that I threw together to meet a need I have until I get around to making a proper implimentation. Use at your own risk.

Send message to discord with list of new/removed games

Provided with no warranty of any sort - run at your own risk.

I will not make any changes/updates/etc. upon request. If I update it for myself I will push changes to github for anyone else to have.

Put this script in a folder somewhere and always run it from that folder. Script will create extra files that will be used in future runs.

Map your share that contains the games folder using the same user you run this script as

# Basic Setup Guide 
Requirements: Already running GameVault server. A drive mapping to the folder containing the games


First pt 1, copy the script into a folder somewhere on your system and always run it from this folder.


First pt 2, add variables as needed - defaults should be fine but you will need to set your Discord webhook URL, and RoleID to be @'d if desired (leave blank if not desired)


Second, run the script as the SAME user as used for the drive mapping 


Third, the script will prompt you to select the games folder - do this


Fourth, the script will then grab a list of all games in the games folder and save this as a txt file.


Fifth, add new games or remove games from the games folder


Sixth, run the script again and it will detect changes and ask you to notify via discord webhook message - say yes


Finally, the message will be sent containing a list of new/removed games.


# This script does not do really any error handling and has not been tested for messages that exceed the max character limit for webhook messages 
use at your own risk or change to fit your needs.

# Future plans
This was created to tide me over until I get around to making a PR with this functionality directly within GameVault (not using Powershell :P don't worry) 

I do not plan to update this script unless I happen to find a major issue in my own use of it.

I'll get around to the "official" implimentation eventually <3

