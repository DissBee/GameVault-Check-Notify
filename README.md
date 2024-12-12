# GameVault-Check-Notify
A script to check your GameVault "Games" directory and send a Discord webhook message with the changes (games added or removed)

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

