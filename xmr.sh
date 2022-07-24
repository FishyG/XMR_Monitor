#!/bin/bash

#Colors (use ${COLOR_NAME})
CLEAR='\033[0m'
WHITE='\033[1;37m'
BLACK='\033[1;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT_GRAY='\033[1;30m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
LIGHT_YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;34m'
LIGHT_PURPLE='\033[1;35m'
LIGHT_CYAN='\033[0;36m'

# 
if [[ "$1" =~ ^([rR][eE][sS][uU][mM][eE]|[-][rR][eE][sS][uU][mM][eE]|[-][rR])$ ]]
then
	# Send "r" command to XMRig to resume
                tmux send-keys -t XMRig r
	echo -e "${LIGHT_GREEN}"
	echo "#################"
	echo "# Resumed XMRig #"
	echo "#################"
fi

#
if [[ "$1" =~ ^([pP][aA][uU][sS][eE]|[-][pP][aA][uU][sS][eE]|[-][pP])$ ]]
then
	# Send "h" command to XMRig to pause the miner
                tmux send-keys -t XMRig p
        echo -e "${LIGHT_RED}"
	echo "#################"
	echo "# Stopped XMRig #"
	echo "#################"
fi

# Only show XMRig status
if [[ "$1" =~ ^([xX][mM][rR][iI][gG]|[-][xX][mM][rR][iI][gG]|[-][xX])$ ]]
then
        echo -ne "${CYAN}#\n#${CLEAR} TMUX: "
	[[ -n $(pgrep tmux) ]] && echo -ne "${GREEN}Running: ${CLEAR}\n" || echo -ne "${RED}Not Running: ${CLEAR}\n"
	echo -e "${CYAN}#"

	echo -ne "#${CLEAR} XMRIG: "
	[[ -n $(pgrep xmrig) ]] && echo -ne "${GREEN}Running${CLEAR}\n" || echo -ne "${RED}Not Running: ${CLEAR}\n"
	[[ -n $(pgrep xmrig) ]] && XMRIG=1 || XMRIG=0

	if (($XMRIG==1))
	then
        	# Send "h" command to xmrig to get hashrate
        	tmux send-keys -t XMRig h ENTER

        	# Capture it's output
        	echo -ne "${CYAN}#${PURPLE} Hashrate: ${CLEAR}"
		counter=1
		while [ $counter -le 10 ]
		do
			IT=$(tmux capture-pane -p -t XMRig | tail -"${counter}" | head -1)
       			echo -ne "$IT H/s${CLEAR}\n"
			((counter++))
		done

		# Send "h" command to xmrig to get hashrate
                tmux send-keys -t XMRig h ENTER

                # Capture it's output
                echo -ne "${CYAN}#${CLEAR} Hashrate: ${CLEAR}"
                IT=$(tmux capture-pane -p -t XMRig | tail -2 | head -1)
                echo -ne "${LIGHT_PURPLE}$IT H/s${CLEAR}\n"

		read -p "Go to XMRig session? [Yy] " -n 1 -r
		echo    # (optional) move to a new line
		if [[ ! $REPLY =~ ^[Yy]$ ]]
		then
    			[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
		fi
	fi
		if (($XMRIG==1))
		then
			tmux attach -t XMRig
		fi
		if (($XMRIG==0))
		then
			tmux new-session -d -s XMRig 'sudo /home/jessy-server/xmrig/build/xmrig'
			tmux attach -t XMRig
		fi

	exit 0
fi

# To edit this file
if [[ "$1" =~ ^([eE][dD][iI][tT]|[eE]|[-][eE][dD][iI][tT]|[-][eE])$ ]]
then
	nano xmr.sh
	exit 0
fi

# Display Help info
if [[ "$1" =~ ^([hH][eE][lL][pP]|[-][hH]|[hH]|[-][hH][eE][lL][pP])$ ]]
then
	echo "###############################################"
	echo "#                                             #"
	echo "# HELP MENU                                   #"
	echo "#                                             #"
    echo "# Use -p or -pause to pause XMRig mining      #"
    echo "# Use -r or -resume to resume XMRig mining    #"
	echo "# Use -e or -edit to edit the code            #"
	echo "# Use -x or -xmrig to go to the XMRig session #"
	echo "# Use -t or -temp to show temp                #"
	echo "# Use -h or -help to view this menu           #"
	echo "#                                             #"
	echo "###############################################"
	exit 0
fi

echo -ne "${CYAN}\n#### XMR Monitor ################\n${CLEAR}"

echo -ne "${CYAN}#\n#${CLEAR} TMUX: "
[[ -n $(pgrep tmux) ]] && echo -ne "${GREEN}Running: ${CLEAR}\n" || echo -ne "${RED}Not Running: ${CLEAR}\n"
echo -e "${CYAN}#"

echo -ne "#${CLEAR} XMRIG: "
[[ -n $(pgrep xmrig) ]] && echo -ne "${GREEN}Running${CLEAR}\n" || echo -ne "${RED}Not Running: ${CLEAR}\n"
[[ -n $(pgrep xmrig) ]] && XMRIG=1 || XMRIG=0

if (($XMRIG==1))
then
	# Send "h" command to xmrig to get hashrate
	tmux send-keys -t XMRig h ENTER

	# Capture it's output
        echo -ne "${CYAN}#${LIGHT_GRAY} Hashrate: ${CLEAR}"
        IT=$(tmux capture-pane -p -t XMRig | tail -2 | head -1 | awk 'NR==1{print $7}')
        echo -ne "${LIGHT_PURPLE}$IT H/s${CLEAR}\n"
fi

echo -ne "${CYAN}#\n#${CLEAR} MONEROD: "
[[ -n $(pgrep monerod) ]] && echo -ne "${GREEN}Running: \033[0m\n" || echo -ne "${RED}Not Running: ${CLEAR}\n"
[[ -n $(pgrep monerod) ]] && MONEROD=1 || MONEROD=0

echo -ne "${CYAN}# ${LIGHT_GRAY}BlockChain size: ${LIGHT_PURPLE}"
du -h /mnt/hdd600/monero/blockchain | tail -1 | awk  '{print $1}'

if (($MONEROD==1))
then
        # Capture monerod's output
        IT=$(tmux capture-pane -p -t Monerod | grep total | tail -1 | cut -d' ' -f 5-)
        IT=${IT:1}
        echo -e "${CYAN}# ${LIGHT_PURPLE}${IT::-1}${CLEAR}"
fi

if [[ "$1" =~ ^([tT][eE][mM][pP]|[-][tT][eE][mM][pP]|[-][tT])$ ]]
then
	echo -e "${CYAN}#${CLEAR}"
	echo -e "${CYAN}#${CLEAR} CPU:"
	echo -ne "${CYAN}# ${YELLOW}"

	sensors | grep temp1 | head -2 | tail -1 | awk 'BEGIN{ORS=""} { printf $1}'
	echo -ne "${LIGHT_GREEN}        "
	sensors | grep temp1 | head -2 | tail -1 | awk 'BEGIN{ORS=""} { printf $2}'
	echo -ne "${CLEAR} "
	sensors | grep temp1 | head -2 | tail -1 | awk 'BEGIN{ORS=""} { printf $3}'
	echo -ne "${CLEAR} "
	sensors | grep temp1 | head -2 | tail -1 | awk 'BEGIN{ORS=""} { printf $4}'
	echo -ne " "
	sensors | grep temp1 | head -2 | tail -1 | awk 'BEGIN{ORS=""} { printf $5}'
	echo -e "${CLEAR} "

	echo -ne "${CYAN}# ${YELLOW}"
	sensors | grep power1 | awk 'BEGIN{ORS=""} { printf $1}'
	echo -ne "${LIGHT_GREEN}      "
	sensors | grep power1 | awk 'BEGIN{ORS=""} { printf $2}'
	echo -ne " "
	sensors | grep power1 | awk 'BEGIN{ORS=""} { printf $3}'
	echo -ne "${CLEAR} "
	sensors | grep power1 | awk 'BEGIN{ORS=""} { printf $4}'
	echo -ne "${CLEAR} "
	sensors | grep power1 | awk 'BEGIN{ORS=""} { printf $5}'
	echo -ne " "
	sensors | grep power1 | awk 'BEGIN{ORS=""} { printf $6}'
	echo -ne "${CLEAR} "
	sensors | grep power1 | awk 'BEGIN{ORS=""} { printf $7}'
	echo -ne "${CLEAR} "
	echo ""
fi
echo -ne "${CYAN}#\n#################################\n"
