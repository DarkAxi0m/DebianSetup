#!/bin/bash

# Guess the interface name (assuming there's only one non-loopback interface)
interface_name=$(ip -o link show | awk -F': ' '{if ($2 != "lo") print $2; exit}')

# Prompt for network configuration details
read -p "Enter the desired IP address: " ip_address
read -p "Enter the subnet mask: " subnet_mask
read -p "Enter the gateway address: " gateway
read -p "Enter DNS server 1: " dns1
read -p "Enter DNS server 2: " dns2

# Backup the original network configuration file
sudo cp /etc/network/interfaces /etc/network/interfaces.bak

# Create a new network configuration file
sudo tee /etc/network/interfaces > /dev/null << EOL
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

# The primary network interface
iface $interface_name inet6 auto

auto $interface_name
iface $interface_name inet static
    address $ip_address
    netmask $subnet_mask
    gateway $gateway
    dns-nameservers $dns1 $dns2
EOL

# Restart the networking service to apply the changes
sudo service networking restart

echo "Static IP configuration has been applied."
