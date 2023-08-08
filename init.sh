#!/bin/bash



interface_name=$(ip a | grep "^[0-9]:" | grep -v lo: | cut -d ":" -f2 | xargs)
current_ip=$(ip -o -4 addr show dev $interface_name | awk '{split($4, a, "/"); print a[1]}')

echo "interface detected: ${interface_name}"
echo "current ip: ${current_ip}"

read -p "Do you want to set up a static IP address? (y/n): " setup_static_ip
read -p "Do you want to install Docker? (y/n): " install_docker

if [ "$setup_static_ip" == "y" ]; then
    default_subnet_mask="255.255.255.0"
    default_gateway="10.1.1.1"
    default_dns="10.1.1.10"
    read -p "Enter the desired IP address: " ip_address
    read -p "Enter subnet mask [$default_subnet_mask]: " subnet_mask
    subnet_mask=${subnet_mask:-$default_subnet_mask}
    
    read -p "Enter gateway [$default_gateway]: " gateway
    gateway=${gateway:-$default_gateway}
    
    read -p "Enter DNS server 1 [$default_dns]: " dns1
    dns1=${dns1:-$default_dns}
    
    
    # Backup the original network configuration file
    cp /etc/network/interfaces /etc/network/interfaces.bak
    
    # Create a new network configuration file
    tee /etc/network/interfaces > /dev/null << EOL
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
    service networking restart

    echo "Static IP configuration has been applied."
else
    echo "Static IP setup was skipped."
fi


# Prompt to install Docker


if [ "$install_docker" == "y" ]; then
   # Install Docker dependencies
     apt-get update
     apt-get install -y ca-certificates curl gnupg

    # Add Docker GPG key
     install -m 0755 -d /etc/apt/keyrings
     curl -fsSL https://download.docker.com/linux/debian/gpg |  gpg --dearmor -o /etc/apt/keyrings/docker.gpg
     chmod a+r /etc/apt/keyrings/docker.gpg

    # Add Docker repository to sources.list.d
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker
     apt-get update
     apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Start and enable Docker
     systemctl start docker
     systemctl enable docker

    # Test Docker
     docker run hello-world

usermod -aG docker chris


    echo "Docker has been installed and enabled."
else
    echo "Docker installation was skipped."
fi
