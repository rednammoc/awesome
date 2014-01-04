#!/bin/bash
ACTION=`zenity --width=90 --height=200 --list --radiolist --text="Select logout action" --title="Logout" --column "Choice" --column "Action" TRUE Shutdown FALSE Reboot FALSE LockScreen FALSE Suspend`

if [ -n "${ACTION}" ];then
case $ACTION in
  Shutdown)
    zenity --question --text "Are you sure you want to halt?" && sudo halt
    ;;
  Reboot)
    zenity --question --text "Are you sure you want to reboot?" && sudo reboot
    ;;
  Suspend)
    sudo pm-suspend
    ;;
  LockScreen)
    slock
    ;;
  esac
fi
