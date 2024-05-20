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
# contact: jmarcelogimenez@gmail.com
#
# Description:
#	Converts an only row file data (gdb array), to vector in Octave format
# ----------------------------------------------------------------------------------------#
#

cut -d "=" -f 2 -s $1 > aux
mv -f aux $1
tr -s "},{" " " < $1 > aux
mv -f aux $1
awk '{for(NR=1;NR<=NF;NR+=3){print $NR,$(NR+1),$(NR+2)}}' $1 > aux
mv -f aux $1
column -t $1 > aux
mv -f aux $1
