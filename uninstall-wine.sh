#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
ALREADYINSTALLED="wine-"

if [[ $EUID -ne 0 ]]; then
   printf "${RED}This script must be run as root. Try using sudo. \r\nExiting...\r\n${NC}"
   exit 1
fi


carriage_return () {
printf "\r\n"
}

print_done () {
printf "${GREEN} done.\r\n"
}

print_not_installed () {
printf "${RED}Wine isn't installed. Nothing to remove.\r\nExiting..."
carriage_return
}

uninstall () {
    printf "${NC}Uninstalling WineHQ Stable package... "
    APTOUT=`sudo apt-get remove winehq-stable -y`
    print_done
    printf "${GREEN}Uninstall completed.\r\n${NC}"
    exit
}

uninstall_purge () {
    printf "${NC}Uninstalling WineHQ Stable package & purging config files... "
    APTOUT=`sudo apt-get remove winehq-stable --purge -y`
    print_done
    printf "${NC}Cleaning up..."
    sudo apt autoremove &> /dev/null
    printf "${GREEN}Uninstall completed.\r\n${NC}"
    exit
}

terminate () {
printf "${RED}Terminating..."
carriage_return
exit 1
}

verify_uninstall() {
read -r -p "Are you sure you want to continue with the uninstallation? [y/n] " input
  case $input in
    [yY][eE][sS]|[yY])
  verify_purge
  ;;
    [nN][oO]|[nN])
  terminate
       ;;
     *)
  terminate
       ;;
  esac
}

verify_purge() {
read -r -p "Do you want to remove Wine's configuration files as well? [y/n] " input
  case $input in
    [yY][eE][sS]|[yY])
  uninstall_purge
  ;;
    [nN][oO]|[nN])
  uninstall
       ;;
     *)
     printf "${RED}Invalid response.${NC}"
  carriage_return
  verify_purge
       ;;
  esac
}

printf "${NC}Checking if Wine is installed..."
carriage_return
WOUT=`wine --version | grep "wine-"`

case $WOUT in

  *"$ALREADYINSTALLED"*)
  verify_uninstall
    ;;
esac

print_not_installed
