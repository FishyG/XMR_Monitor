#!/bin/bash

#Colors (use ${COLOR})
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
        echo -ne "${CYAN}#${CLEAR} Hashrate: ${CLEAR}"
        IT=$(tmux capture-pane -p -t XMRig | tail -2 | head -1 | awk 'NR==1{print $6}')
        echo -ne "${LIGHT_PURPLE}$IT H/s${CLEAR}\n"
fi

echo -ne "${CYAN}#\n#${CLEAR} MONEROD: "
[[ -n $(pgrep monerod) ]] && echo -ne "${GREEN}Running: \033[0m\n" || echo -ne "${RED}Not Running: ${CLEAR}\n"
[[ -n $(pgrep monerod) ]] && MONEROD=1 || MONEROD=0

if (($MONEROD==1))
then
        # Capture monerod's output
        IT=$(tmux capture-pane -p -t Monerod | grep total | tail -1 | cut -d' ' -f 5-)
        IT=${IT:1}
        echo -e "${CYAN}# ${LIGHT_PURPLE}${IT::-1}\n${CYAN}#${CLEAR}"
fi

echo -e "${CYAN}#################################"
