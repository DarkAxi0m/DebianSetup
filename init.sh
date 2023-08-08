#!/bin/bash

interface_name=$(ip -o link show | awk -F': ' '{if ($2 != "lo") print $2; exit}')
default_subnet_mask="255.255.255.0"
default_gateway="10.1.1.1"
default_dns="10.1.1.10"

echo "interface detected: ${interface_name}"

read -p "Enter the desired IP address: " ip_address
read -p "Enter subnet mask [$default_subnet_mask]: " subnet_mask
subnet_mask=${subnet_mask:-$default_subnet_mask}

read -p "Enter gateway [$default_gateway]: " gateway
gateway=${gateway:-$default_gateway}

read -p "Enter DNS server 1 [$default_dns]: " dns1
dns1=${dns1:-$default_dns}

read -p "Enter DNS server 1 [$default_dns]: " dns1
dns1=${dns1:-$default_dns}  # Use default if input is empty

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
    dns-nameservers $dns1
EOL

# Restart the networking service to apply the changes
sudo service networking restart
ip address
echo "Static IP configuration has been applied."
