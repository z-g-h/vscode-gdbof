#!/bin/sh
#
# ----------------------------- CIMEC-INTEC ----------------------------------- 
# ------- Centro Internacional de Metodos Computacionales en Ingeniería -------
# -------- (International Center for Numerical Methods in Engineering) --------  
# ----------------------- Santa Fe - Argentina --------------------------------
#
#    License
#
#    OpenFOAM is free software; you can redistribute it and/or modify it
#    under the terms of the GNU General Public License as published by the
#    Free Software Foundation; either version 2 of the License, or (at your
#    option) any later version.
#
#    OpenFOAM is distributed in the hope that it will be useful, but WITHOUT
#    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
#    for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with OpenFOAM; if not, write to the Free Software Foundation,
#    Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
#
# Created By:
# J.M. Gimenez(1), S.Marquez Damian(1), N. Nigro(1)
#
# (1)CIMEC (INTEC-UNL-CONICET), Santa Fe, Argentina
#
#
#
# contact: jmarcelogimenez@gmail.com
#
# Description:
#   Makes an gdb macro in runtime
# ----------------------------------------------------------------------------------------
file=`cat file.gdbof`
isBou=`cut -d" " -f1 < $file`
indx=`cut -d" " -f2 < $file`
indxb=`cut -d" " -f3 < $file`

sed 's/$arg0/'$1'/g' < ~/OpenFOAM/gdbOF/macroTemplate.gdb > ~/OpenFOAM/gdbOF/macroTemp.gdb
sed 's/$arg1/'$isBou'/g' < ~/OpenFOAM/gdbOF/macroTemp.gdb > auxTemp.gdb
mv auxTemp.gdb ~/OpenFOAM/gdbOF/macroTemp.gdb
sed 's/$arg2/'$indx'/g' < ~/OpenFOAM/gdbOF/macroTemp.gdb > auxTemp.gdb
mv auxTemp.gdb ~/OpenFOAM/gdbOF/macroTemp.gdb

sed 's/$arg3/'$indxb'/g' < ~/OpenFOAM/gdbOF/macroTemp.gdb > auxTemp.gdb
mv auxTemp.gdb ~/OpenFOAM/gdbOF/macroTemp.gdb


#sed 's/$arg0/'$1'/g' < ~/OpenFOAM/gdbOF/macroTemplate.gdb > ~/OpenFOAM/gdbOF/macroTemp.gdb
#sed 's/$arg1/'$2'/g' < ~/OpenFOAM/gdbOF/macroTemp.gdb > auxTemp.gdb
#mv auxTemp.gdb ~/OpenFOAM/gdbOF/macroTemp.gdb
#sed 's/$arg2/'$3'/g' < ~/OpenFOAM/gdbOF/macroTemp.gdb > auxTemp.gdb
#mv auxTemp.gdb ~/OpenFOAM/gdbOF/macroTemp.gdb
#if $4!="" 
#then
#	sed 's/$arg3/'$4'/g' < ~/OpenFOAM/gdbOF/macroTemp.gdb > auxTemp.gdb
#	mv auxTemp.gdb ~/OpenFOAM/gdbOF/macroTemp.gdb
#else
#	sed 's/$arg3/0/g' < ~/OpenFOAM/gdbOF/macroTemp.gdb > auxTemp.gdb
#	mv auxTemp.gdb ~/OpenFOAM/gdbOF/macroTemp.gdb
#fi
#sed 's/$arg3/'$4'/g' < ~/OpenFOAM/gdbOF/macroTemp.gdb > auxTemp.gdb
#mv auxTemp.gdb ~/OpenFOAM/gdbOF/macroTemp.gdb
#cat ~/OpenFOAM/gdbOF/macroTemp.gdb

