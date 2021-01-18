#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

ALREADYINSTALLED='winehq-stable is already the newest version'

if [[ $EUID -ne 0 ]]; then
   printf "${RED}This script must be run as root. Try using sudo. \r\nExiting...\r\n${NC}"
   exit 1
fi

terminate () {
printf "${RED}Terminating..."
carriage_return
exit 1
}

carriage_return () {
printf "\r\n"
}

print_done () {
printf "${GREEN} done.\r\n"
}

install_wine () {
printf "${NC}Getting repo key from WineHQ..."
wget -nc https://dl.winehq.org/wine-builds/winehq.key &> /dev/null
print_done
printf "${NC}Adding key..."
sudo apt-key add winehq.key &> /dev/null
print_done
printf "${NC}Adding WineHQ repository to APT (focal main)..."
sudo apt-add-repository ‘deb https://dl.winehq.org/wine-builds/ubuntu focal main &> /dev/null
print_done
printf "${NC}Updating APT cache..."
sudo apt-get update &> /dev/null
print_done
printf "${NC}Installing WineHQ Stable package..."

APTOUT=`sudo apt-get install --install-recommends winehq-stable -y | grep "winehq-stable is already the newest version"`
print_done

case $APTOUT in

  *"$ALREADYINSTALLED"*)
    printf "${CYAN}Looks like winehq-stable is already installed.\r\n"
    ;;
esac

printf "${NC}Install completed. Getting Wine version...${NC}"
carriage_return
WOUT=`wine --version`
printf "${NC}Command ${GREEN}wine --version ${NC}returned ${RED}${WOUT}"
carriage_return
printf "${GREEN}Looks like everything's working."
carriage_return
printf "${NC}Cleaning up..."
sudo apt autoremove &> /dev/null
printf "${NC}Done! Test it out by running a command like ${GREEN}wine notepad.exe${NC}."
carriage_return
}

verify_install() {
read -r -p "Would you like to install Wine? [y/n] " input
  case $input in
    [yY][eE][sS]|[yY])
  install_wine
  ;;
    [nN][oO]|[nN])
  terminate
       ;;
     *)
  terminate
       ;;
  esac
}

verify_install
