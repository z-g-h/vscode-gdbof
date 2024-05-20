#!/bin/bash
#
# USAGE: ./installgdbOF
#
# Created By:
# J.M. Gimenez(1), S.Marquez Damian(1), N. Nigro(1)
#
# (1)CIMEC (UNL-CONICET), Santa Fe, Argentina
#
#
# contact: jmarcelogimenez@gmail.com
#
# March 2020
#
set -e
echo "-----------------------------------------------------"
echo "Installing gdbOF..."
echo "-----------------------------------------------------"
echo "Making sure that you have OpenFOAM debug compiled"
echo "-----------------------------------------------------"
if [ "Debug" != "$WM_COMPILE_OPTION" ]
then
    echo "Error: The parameter \$WM_PROJECT_DIR: " $WM_COMPILE_OPTION " is not \"Debug\""
    echo "    Change this flag in \$WM_PROJECT_DIR/etc/bashrc to perform the instalation"
    exit 1
else
	if [ -f $FOAM_LIBBIN/libtriSurface.so ]
	then
		if cat src/findFace/Make/options | grep -q "ltriSurface"
		then
			echo "Skipping Make/options modification"
		else
			sed -i 's/n$/n \\/'  src/findFace/Make/options
			sed -i '$ a\    -ltriSurface'  src/findFace/Make/options

			sed -i 's/n$/n \\/'  src/findFacesCell/Make/options
			sed -i '$ a\    -ltriSurface'  src/findFacesCell/Make/options
		fi
	fi
fi

if ! cat ~/.gdbinit | grep -q "gdbOFexpanded.gdb"
then
	echo "# gdbOF sources #" >> ~/.gdbinit
	echo "source $PWD/gdbOF/gdbOFexpanded.gdb" >> ~/.gdbinit
	echo "set auto-load safe-path /" >> ~/.gdbinit
fi

sed "s|_GDBOFPATH|$PWD|g" gdbOF/gdbOF.gdb > gdbOF/gdbOFexpanded.gdb

echo "export GDBOFPATH="$PWD >> ~/.bashrc

echo "export GDBOFPATH="$PWD >> ~/.bashrc

echo "compiling gdbOF_apps..."
cd src/findCell
wclean
wmake
cd ../findFace
wclean
wmake
cd ../findFacesCell
wclean
wmake

echo "-----------------------------------------------------"
echo "End Installation.."
echo "-----------------------------------------------------"
set +e

