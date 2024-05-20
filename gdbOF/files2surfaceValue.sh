#!/bin/sh
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
# contact: jmarcelogimenez@gmail.com
#
# Description:
#	Makes one file for each face
# ----------------------------------------------------------------------------------------
row=`cat aux | grep -n "Face List" | cut -d ":" -f1`
row=`expr $row + 1`
n=`head -$row aux | tail -1`

sh  ~/OpenFOAM/gdbOF/printTail.sh $n > auxF

while [  $n -gt 0 ]; do
	f=`expr $n - 1`
	head -$n auxF | tail -1 > data$f.dat			
	n=`expr $n - 1`
done
         

#head -6 auxF | tail -1 >data5.dat			
#head -5 auxF | tail -1 >data4.dat
#head -4 auxF | tail -1 >data3.dat
#head -3 auxF | tail -1 >data2.dat
#head -2 auxF | tail -1 >data1.dat
#head -1 auxF | tail -1 >data0.dat

rm auxF
