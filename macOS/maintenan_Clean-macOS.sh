#!/bin/bash

echo "Starting maintenance script..."

# Prompt for password and save it in memory for the remainder of the script
echo -n "Enter your password: "
read -s password
echo ""

# Clear the caches
echo "Clearing caches..."
echo $password | sudo -S purge

# Check for updates and install them
echo "Checking for updates..."
echo $password | sudo -S softwareupdate -i -a

# Update apps
echo "Updating apps..."
echo $password | sudo -S softwareupdate --schedule on

# List apps not used for the past 90 days
echo "Listing apps not used for the past 90 days..."
unused_apps=$(find /Applications -type f -mtime +90d -name "*.app" -maxdepth 1)
echo "$unused_apps"

# Prompt to delete unused apps
if [[ -n "$unused_apps" ]]
then
  echo "The above apps have not been used for the past 90 days. Do you want to delete them? (y/n)"
  read response
  if [[ "$response" =~ ^[Yy]$ ]]
  then
    echo "Deleting unused apps..."
    echo $password | sudo -S rm -rf $unused_apps
  else
    echo "Unused apps will not be deleted."
  fi
else
  echo "No apps have been found that were not used for the past 90 days."
fi

# Remove remaining unused files
echo "Removing remaining unused files..."
echo $password | sudo -S rm -vrf ~/Library/Caches/*
echo $password | sudo -S rm -vrf /Library/Caches/*
echo $password | sudo -S rm -vrf /Users/Shared/*

# Repair disk permissions
echo "Repairing disk permissions..."
echo $password | sudo -S diskutil verifyPermissions /
echo $password | sudo -S diskutil repairPermissions /

# Restart the computer
echo "Restarting the computer..."
echo $password | sudo -S shutdown -r now

# Warn about password and purge it from memory
echo "WARNING: Your password was used in this script and was stored in memory. Please change your password immediately."
unset password
