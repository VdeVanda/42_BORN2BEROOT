#!/bin/bash
# above line tells the system that this script should be executed in bash
# without this, the current shell would be used to execute the script, meaning that it
# could be bash, but could also be any other one 

# THE ARCHITECTURE OF YOUR OPERATING SYSTEM AND ITS KERNEL VERSION
# uname -a: shows info about the system.
architecture=$(uname -a)

# THE NUMBER OF PHYSICAL PROCESSORS
# lscpu: shows more detailed info abut the sysm
# grep: fetches the specified pattern
# awk -F: splits each line at the colon (:)
# grep -o -E '[0-9]+': extracts all digits from the input, -o is for printing the matching part and -E is for RegEx
# head -1: prints only the 1st line of the output
sockets=$(lscpu | grep 'Socket(s)' | awk -F: '{print $2}' | grep -o -E '[0-9]+' | head -1)

#THE NUMBER OF VIRTUAL PROCESSORS
vCPU=$(lscpu | grep 'CPU(s)' | awk -F: '{print $2}' | grep -o -E '[0-9]+' | head -1)

# THE CURRENT AVAILABLE RAM ON YOUR SERVER 
# AND ITS UTILIZATION RATE AS A PERCENTAGE
# free command displays the RAM, which is volatile, 
# since its deleted when the computer's powered off
mem_used=$(free -m | grep -A 2 'used' | sed -n '2p' | awk '{print $3}')
mem_free=$(free -m | grep -A 2 'used' | sed -n '2p' | awk '{print $2}')
mem_percent=$(free | awk '/Mem/{printf("%.2f%%", $3/$2*100)}')

# THE CURRENT AVAILABLE STORAGE ON YOUR SERVER AND ITS UTILIZATION RATE AS A PERCENTAGE
# disk space shows info about the HD memory
disk_space_used=$(df -BM | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} END {print ut}')
disk_space_total=$(df -Bg | grep '^/dev/' | grep -v '/boot$' | awk '{ft += $2} END {print ft}')
disk_usage_percent=$(df -BM | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} {ft+= $2} END {printf("%d%%"), ut/ft*100}')

# THE CURRENT UTILIZATION RATE OF YOUR PROCESSORS AS A PERCENTAGE
# amount of CPU resources being used, namely processes executing 
# or waiting to be executed in a given time
# Get the CPU load using the 'top -bn1' command
# The 'grep' command filters lines starting with '%Cpu'
# The 'cut' command removes the first 8 characters
# The 'xargs' command removes extra spaces
# The 'awk' command sums the user and system CPU usage and prints 
# the result as a percentage
cpu_load=$(top -bn1 | grep '^%Cpu' | cut -c 9- | xargs | awk '{printf("%.1f%%"), $1 + $3}')

# THE DATE AND TIME OF THE LAST REBOOT
# last boot retrieves the last system boot time
# The '-b' flag tells 'who' to display the last system boot time.
# The output of the 'who -b' command is piped to 'grep' to filter 
# lines containing the word 'boot'.
# The '-F "boot  "' option sets the field separator to "boot  " 
# (note the two spaces after 'boot').
# '{print $2}' prints the second field, which contains the date and time 
# of the last boot.
last_boot=$(who -b | grep 'boot' | awk -F "boot  " '{print $2}')

# WHETHER LVM IS ACTIVE OR NOT
# partitions are ways to divide a disk into separate sections, whilst LVM,
# Logical Volume Manager, are a way to approach a more flexible disk management,
# since it allows dynamically resizing disk size
lvm_use=$(lsblk | grep 'lvm' | ( if read -r line; then echo "yes"; else echo "no"; fi ))

# THE NUMBER OF ACTIVE CONNECTIONS
# TRANSMISSION PROTOCOL CONNECTIONS are ways to enable safe communication through the internet
# sending data from one ip to another securely through data packets
ctcp=$(ss -Ht state established | wc -l)

# THE NUMBER OF USERS USING THE SERVER
# number of users logged in the system
user_log=$(users | wc -w)

# THE IPV4 ADDRESS OF YOUR SERVER AND ITS MAC (MEDIA ACCESS CONTROL) ADDRESS
# hostname -I stands for private ip
network_ip=$(hostname -I)
# MEDIA ACCESS CONTROL ADDRESS is a unique id assigned to a network interface card 
# MAC addresses can be used to send data between different devices within the same network
mac_address=$(ip link show | awk '$1 == "link/ether" {print $2}')

# THE NUMBER OF COMMANDS EXECUTED WITH THE SUDO PROGRAM
# number of times sude has been executed on the system
sudo=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

# wall sends a message to all terminals
# tty stands for teletypewriter, which is the physical terminal connected to a computer, 
# such as a keyboard and monitor
# pts stands for pseudo terminal slave, representing virtual terminals that are created for remote
# connections such as SSH
wall "	#Architecture: $architecture
	#CPU physical : $sockets
	#vCPU: $vCPU
	#Memory Usage: $mem_used/${mem_free}MB ($mem_percent)
	#Disk Usage: $disk_space_used/${disk_space_total}Gb ($disk_usage_percent)
	#CPU load: $cpu_load%
	#Last boot: $last_boot
	#LVM use: $lvm_use
	#Connections TCP : $ctcp ESTABLISHED
	#User log: $user_log
	#Network: IP $network_ip ($mac_address)
	#Sudo : $sudo cmd"
