#!/usr/bin/env bash

abort()
{
echo >&2 '
***************
*** ABORTED ***
***************
'	
echo "An error occurred. Exiting..." >&2
exit 1
}
trap 'abort' 0
set -euo pipefail

yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }

#needed defaults and variables:
declare -A assArray2=( [HDD]=Samsung [Monitor]=Dell [Keyboard]=A4Tech )
declare -A MASTERNODE_PARAMS
choose_diferent_port="n"
C_WALLET_NAME=""
P_DATA_DIRECTORY=""
P_MASTERNODES_PATH=""


getWalletName()
{
	echo "Enter the name of your wallet. For example: 'superdoge'".
	read C_WALLET_NAME 
	#lower case
	C_WALLET_NAME="${C_WALLET_NAME,,}"
	echo "#######################################################"
}

getWalletDir()
{
	#search for original wallet directory under current directory
	if [ -f "$(pwd)/.${C_WALLET_NAME}/wallet.dat" ] 
	then
		echo "${C_WALLET_NAME} data directory found in '$(pwd)'!"
		echo "#######################################################"
		P_DATA_DIRECTORY="$(pwd)/.${C_WALLET_NAME}" 

	else
		#search for original wallet directory under home
		if [ -f "/home/$(whoami)/.${C_WALLET_NAME}/wallet.dat" ]
		then
			echo "${C_WALLET_NAME} data directory found in '/home/$(whoami)/.${C_WALLET_NAME}' !"
			echo "#######################################################"
			P_DATA_DIRECTORY="/home/$(whoami)/.${C_WALLET_NAME}"
		else
			if [ -f "$(whoami)/.${C_WALLET_NAME}/wallet.dat" ] 
			then
				echo "${C_WALLET_NAME} data directory found in '/$(whoami)/.${C_WALLET_NAME}' !"
				echo "#######################################################"
				P_DATA_DIRECTORY="/$(whoami)/.${C_WALLET_NAME}"
			else
				echo "${C_WALLET_NAME} folder not found in '$(pwd)'!"
				echo "Please insert existing data directory path for '.${C_WALLET_NAME}/' to continue or press Ctrl + C to cancel"
				echo "Example: /home/$(whoami)/.${C_WALLET_NAME} "
				read P_DATA_DIRECTORY
				echo "#######################################################"
				[ ${P_DATA_DIRECTORY::1} != "/" ] && P_DATA_DIRECTORY="/${P_DATA_DIRECTORY}"
       			
				#check if given directory is a valid wallet directory
				while [ ! -f "${P_DATA_DIRECTORY}/wallet.dat" ]
				do
					echo "Given path is not a valid data directory (${P_DATA_DIRECTORY}/wallet.dat file not found)"
					echo "Please enter an valid path or press Ctrl + C to cancel :"
					read P_DATA_DIRECTORY
					echo "#######################################################"
					if [ ${P_DATA_DIRECTORY::1} != "/" ]
	        	        	then
        		        	        P_DATA_DIRECTORY="/${datadirectory}"
               				fi
				done
			fi
		fi
	fi
}

getMasternodesPath()
{
	#set path where masternodes datadir are to be created
	P_MASTERNODES_PATH="$(dirname ${P_DATA_DIRECTORY})"

	echo "Would you like to use '${P_MASTERNODES_PATH}' for masternodes data directories?"
	echo "(If you are not sure, choose Y) Y/N :"
	read CHOOSE_MASTERNODE_PATH
	echo "#######################################################"
	CHOOSE_MASTERNODE_PATH=${CHOOSE_MASTERNODE_PATH,,}
	tmpstr="${CHOOSE_MASTERNODE_PATH}."
	CHOOSE_MASTERNODE_PATH=${tmpstr:0:1}

	if [ ${CHOOSE_MASTERNODE_PATH} != "y" ]
	then
		echo "Please enter full path for masternode datadir : "
		read P_MASTERNODES_PATH
		echo "#######################################################"
		[ ${CHOOSE_MASTERNODE_PATH::1} != "/" ] && P_MASTERNODES_PATH="/${P_MASTERNODES_PATH}"
	
		if [ ! -d "${P_MASTERNODES_PATH}" ]
		then
			echo "${P_MASTERNODES_PATH} does not exists and it will now be created"	
			echo "#######################################################"
			mkdir -p "${P_MASTERNODES_PATH}"
		else
				echo "'${P_MASTERNODES_PATH}' found!"
				echo "#######################################################"
		fi
	fi
}


getNumberOfMasternodes()
{
	echo "How many masternodes do you want to create?"
	read n_masternodes
	echo "#######################################################"
}

getPorts()
{
	echo "Would you like to set a specific listening port instead of system defaults for your wallet connections?"
	echo "(If not sure, choose N) Y/N :"
	read choose_port
	echo "#######################################################"
	#lower case
	choose_port=${choose_port,,}
	#add a dot at the end :)
	tmpstr="${choose_port}."
	#keep only first character
	choose_port=${tmpstr:0:1}

	if 
		[ ${choose_port} == "y" ]
	then 

		if [ ${n_masternodes} -gt 1 ]
		then
			echo "Would you like to use a different listening port for each masternode?"
	        	echo "(If not sure choose N) Y/N :"
			read choose_diferent_port	
			echo "#######################################################"
			choose_diferent_port=${choose_diferent_port,,}
			tmpstr="${choose_diferent_port}."
			choose_diferent_port=${tmpstr:0:1}
		fi
		

		if [ ${choose_diferent_port} != "y" ]
		then
			echo "Insert specific PORT for listening to:"
	                read port
			echo "#######################################################"
			for ((c=1; c<=${n_masternodes}; c++))
			do	
		        	echo "Insert PORT for Masternode N° ${c} :"
	       			read port		
				echo "#######################################################"
				MASTERNODE_LIST[port${c}]=${port}
			done

	                DEFAULT_PORT=( "$ports" )
	        fi
	else
		echo "Usind default port for listening to connections"
		echo "#######################################################"
	fi
	
	if [ ! -z ${choose_diferent_port} ] && [ ${choose_diferent_port} == "y" ]
	then 
		for ((c=1; c<=${n_masternodes}; c++))
		do	
		        echo "Insert PORT for Masternode N° ${c} :"
	       		read ports		
			echo "#######################################################"
			MASTERNODE_LIST[port${c}]=${port}
		done
	fi
}


getExternalIPs()
{
	echo "Use these notations for ipv4 / ipv6 respectively"
	echo "'123.45.67.89' / '[4411:23:23:ab::420:69fa]'"

	for ((c=1; c<=${n_masternodes}; c++))
	do
		echo "Insert Public IP for Masternode N° ${c} :"
		read publicip
		MASTERNODE_LIST[publicip${c}]=${publicip}

		auxip=3+${c}
		ipbind="127.0.0.${auxip}"
		MASTERNODE_LIST[ipbind${c}]=${ipbind}
	done

}




echo "Hello, $(whoami) !!"

getWalletName 
getWalletDir
getMasternodesPath
getNumberOfMasternodes
getPorts
getExternalIPs







echo "Creating ${n_masternodes} masternode directories for ${C_WALLET_NAME} at '${P_MASTERNODES_PATH}'"
echo "PLEASE be pacient..."

for ((c=1; c<=${n_masternodes}; c++))
do
	mkdir "${P_MASTERNODES_PATH}/.masternode${c}/"
	echo ${P_DATA_DIRECTORY}
	echo ${P_MASTERNODES_PATH}
	cp -r -i -t "${P_MASTERNODES_PATH}/.masternode${c}/" "${P_DATA_DIRECTORY}/."	
	echo "${P_MASTERNODES_PATH}/.masternode${c}/"
	
#	ls -a ${P_DATA_DIRECTORY}/. | grep "wallet"   
	rm -r "${P_MASTERNODES_PATH}/.masternode${c}/backups/"
	rm "${P_MASTERNODES_PATH}/.masternode${c}/masternode.conf"
	rm "${P_MASTERNODES_PATH}/.masternode${c}/${C_WALLET_NAME}.conf"
	rm "${P_MASTERNODES_PATH}/.masternode${c}/wallet.dat"
	
#	wallet_cfg="# wallet config file
#bind=${ipbind_list[${c}-1]}
#bind=${publicip_list[${c}-1]}
#logtimestamps=1
#maxconnections=256
#listen=1
#staking=1
#externalip=${publicip_list[${c}-1]}
##masternode=1
##masternodeaddr=
##masternodeprivkey=
#server=1
#rpcallowip=external
#port=7373
#-rpcport=mainet port as default
# -rpcbind=<addr>[::1]:port or 127.0.0.1:port
#  -rpcuser=<user>
#   -rpcpassword=<pw>
#
#"
#	echo "" > myfile.txt
#
#	echo "
#	dash-cli -datadir -getinfo
#	dash-cli -datadir -rpcconnect=<ip>127.0.0.1 -rpcport=mainet port 
#	"
#
#
done










trap : 0

echo >&2 '
************
*** DONE ***
************
'
