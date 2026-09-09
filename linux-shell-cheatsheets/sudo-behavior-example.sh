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


#needed defaults:
choose_diferent_port="n"
USUARIO=""
:
updateAndUpgrade()
{	echo "whoami crudo"	
	echo "Hello  $(whoami) !!"
	USUARIO=$(whoami)
	echo "usando la variable USUARIO=$'(whoami')"
	echo "Hello, usuario ${USUARIO}"
	echo "usando la variable USUARIO=$'(sudo whoami')"
	USUARIO=$(sudo whoami)
	echo "Hello, usuario ${USUARIO}"
	echo "usando $'('sudo whoami)"
	echo "Hello  $(sudo whoami) eaea" >&2
	echo "USANDO SUDO pero antes de echo"
	sudo echo "Hello, $(whoami) !!"
	echo "#######################################################"
	echo "Creando carpetas:"
	echo "Creando carpeta1 sin sudo"
	mkdir carpeta1
	echo "Creando carpeta2 con sudo"
	sudo mkdir carpeta2

	echo $(ls -l)
	rm -d carpeta1
	rm -d carpeta2	
}

updateAndUpgrade

trap : 0

echo >&2 '
************
*** DONE ***
************
'
