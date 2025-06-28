# GameVault-Check-Notify
A collection of scripts that assist with notifying a Discord server of games added/removed from your GameVault server!

## What does it do?
On first run, the script will check your "Games" directory and generate a list of all currently known games. The next run will generate a new list, compare the two lists, and send a Discord webhook message with what has been added or removed.

# IMPORTANT NOTES
These scripts are very low effort - they work, but they may require you to make tweaks to fit your particular setup. 

USE AT YOUR OWN RISK

### I am working on turning this into a proper GameVault plugin - stay tuned!


## Planned changes:

* Option to change the notification to embeds for nicer display of the information, if desired.
* Finish revising this ReadMe at some point
* Script updates - add a custom message, cleanup, usability features, simplifying everything a bit


# Version Info (WIP)

* Powershell version (Windows systems):
* Python version (cross platform):
* Bash version (Linux systems):


# Basic Setup Guide (WIP)
Requirements: Already running GameVault server. A drive mapping to the folder containing the games


First pt 1, copy the script into a folder somewhere on your system and always run it from this folder.


First pt 2, add variables as needed - defaults should be fine but you will need to set your Discord webhook URL, and RoleID to be @'d if desired (leave blank if not desired)


Second, run the script as the SAME user as used for the drive mapping 


Third, the script will prompt you to select the games folder - do this


Fourth, the script will then grab a list of all games in the games folder and save this as a txt file.


Fifth, add new games or remove games from the games folder


Sixth, run the script again and it will detect changes and ask you to notify via discord webhook message - say yes


Finally, the message will be sent containing a list of new/removed games.



# Everything below this point is old and will be revised when I get around it to later :)


### NEW - Python version that also checks if it is run locally on the same system that hosts the games - yay!
New variable: LOCAL_RUN bool 

Now we have python too - neato!


### NEWish - Bash script that does this too but assumes you know what you are doing. Assumes games are on remote host.
### NEW - another version (local only) that tries to do all of this locally if you have your games directory mounted to the local system somehow
Variables:

* SSH_Host="user@address" (set this to be the user@IP/name of the host that holds your games)
* SSH_Port=22 (change this if you use a different port)
* CURRENT_LIST_PATH="./currentlist.txt" (change this if you want)
* GAMES_PATH="/your/path/to/games/directory/on/remote/host"
* DISCORD_HOOK_URL="your hook url goes here"
* DISCORD_ROLE_ID="put your role id to @ here in the proper format"


### Everything below this point is for the powershell version

### Notes
This is a very basic script that I threw together to meet a need I have until I get around to making a proper implimentation. Use at your own risk.

Send message to discord with list of new/removed games

Provided with no warranty of any sort - run at your own risk.

I will not make any changes/updates/etc. upon request. If I update it for myself I will push changes to github for anyone else to have.

Put this script in a folder somewhere and always run it from that folder. Script will create extra files that will be used in future runs.

Map your share that contains the games folder using the same user you run this script as




### This script does not do really any error handling and has not been tested for messages that exceed the max character limit for webhook messages 
use at your own risk or change to fit your needs.

