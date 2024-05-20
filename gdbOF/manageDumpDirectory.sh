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
# (1)CIMEC (INTEC-UNL-CONICET), Santa Fe, Argentina
#
#
# contact: jmarcelogimenez@gmail.com
#
# Description:
#	Manage the vol*Fields dumping.
# ----------------------------------------------------------------------------------------

if [ $1 = "folder_name" ];
then
	ls -F | grep "/" | grep "\(^[0-9]*\/$\|^[0-9]*\.[0-9]*\/$\|^[0-9]*e-\?[0-9]*\/$\|^[0-9]*\.[0-9]*e-\?[0-9]*\/$\)" | cut -d "/" -f1 | tr -s "." "," | sort -g | tr -s "," "." > folder_name
	mv -f folder_name.gdbof aux.gdbof
	tail -n1 aux.gdbof > folder_name.gdbof
	rm aux.gdbof
fi
if [ $1 = "make_dirs" ];
then
	if [ ! -d "gdbOF_dump" ];
	then
		mkdir gdbOF_dump
	fi
	cut -d '"' -f 2 -s time_aux.gdbof > aux.gdbof
	mv -f aux.gdbof time_aux.gdbof
	time=`cat time_aux.gdbof`
	direc='gdbOF_dump/'$time
	if [ ! -d $direc ];
	then
		mkdir $direc
	fi
	echo $direc > direc_name.gdbof
fi
if [ $1 = "include_dim" ];
then			
	aux=`cut -d "=" -f 2 -s dim_aux.gdbof | tr -s "},{" " "`
	sed -e "s/DIM/$aux/g" < ~/OpenFOAM/gdbOF/base_field.foam > aux.gdbof
	mv aux.gdbof auxDump.foam.gdbof
	rm dim_aux.gdbof
fi
if [ $1 = "include_class" ];
then			
	aux=`cut -d '"' -f 2 -s  class_aux.gdbof`
	sed -e "s/CLASS/$aux/g" < auxDump.foam.gdbof > aux.gdbof
	mv aux.gdbof auxDump.foam.gdbof
	rm class_aux.gdbof
fi
if [ $1 = "include_object" ];
then			
	aux=`cut -d '"' -f 2 -s object_aux.gdbof`
	sed -e "s/OBJECT/$aux/g" < auxDump.foam.gdbof > aux.gdbof
	echo $aux > field_name.gdbof
	mv aux.gdbof auxDump.foam.gdbof
	rm object_aux.gdbof
fi
if [ $1 = "include_version" ];
then			
	sed -e "s/VERSION/$WM_PROJECT_VERSION/g" < auxDump.foam.gdbof > aux.gdbof
	mv aux.gdbof auxDump.foam.gdbof
fi
if [ $1 = "include_iv" ];
then		
	size=`wc -l < piv_aux.gdbof`
	sed -e "s/INTERNALSIZE/$size/g" < auxDump.foam.gdbof > aux.gdbof
	mv aux.gdbof auxDump.foam.gdbof

	sed -e "s/INTERNALTYPE/$2/g" < auxDump.foam.gdbof > aux.gdbof
	mv aux.gdbof auxDump.foam.gdbof
	
	if [ $2 = "scalar" ];
	then
		head -n 21 auxDump.foam.gdbof > auxH.gdbof
	else
		head -n 21 auxDump.foam.gdbof > auxH.gdbof
		sed -e 's/^/(/g' piv_aux.gdbof | sed -e 's/$/)/g' > piv_aux2.gdbof
		mv piv_aux2.gdbof piv_aux.gdbof
	fi	
	cat auxH.gdbof piv_aux.gdbof > auxDump.foam.gdbof
	echo ");" >> auxDump.foam.gdbof
	echo "\r" >> auxDump.foam.gdbof
	echo "boundaryField" >> auxDump.foam.gdbof
	echo "{" >> auxDump.foam.gdbof
	rm piv_aux.gdbof
	rm auxH.gdbof
fi
if [ $1 = "include_pv" ];
then		
	name=`cut -d '"' -f 2 -s  bouName_aux.gdbof`
	type=`cut -d '"' -f 2 -s  bouType_aux.gdbof`
	rm bouName_aux.gdbof
	rm bouType_aux.gdbof
	if [ $type = "empty" -o $type = "wedge" -o $type = "zeroGradient" ];
	then
		sed -e "s/BOUNDARYNAME/$name/g" < ~/OpenFOAM/gdbOF/base_boundary1.foam > auxBouDump.foam.gdbof
		sed -e "s/BOUNDARYTYPE/$type/g" < auxBouDump.foam.gdbof > auxi.gdbof
		mv auxi.gdbof auxBouDump.foam.gdbof
		cat auxDump.foam.gdbof auxBouDump.foam.gdbof > aux.gdbof
		mv aux.gdbof auxDump.foam.gdbof
		rm auxBouDump.foam.gdbof
	else
		size=`wc -l < ppv_aux.gdbof`
		sed -e "s/BOUNDARYSIZE/$size/g" < ~/OpenFOAM/gdbOF/base_boundary2.foam > auxBouDump.foam.gdbof
		sed -e "s/BOUNDARYNAME/$name/g" < auxBouDump.foam.gdbof > aux.gdbof
		mv aux.gdbof auxBouDump.foam.gdbof	
		#sed -e "s/BOUNDARYTYPE/$type/g" < auxBouDump.foam > aux
		sed -e "s/BOUNDARYTYPE/fixedValue/g" < auxBouDump.foam.gdbof > aux.gdbof
		mv aux.gdbof auxBouDump.foam.gdbof	
		sed -e "s/BOUNDARYFORMAT/$2/g" < auxBouDump.foam.gdbof > aux.gdbof
		mv aux.gdbof auxBouDump.foam.gdbof
	
		if [ $2 = "scalar" ];
		then
			head -n 6 auxBouDump.foam.gdbof > auxH.gdbof
		else
			head -n 6 auxBouDump.foam.gdbof > auxH.gdbof
			sed -e 's/^/(/g' ppv_aux.gdbof | sed -e 's/$/)/g' > ppv_aux2.gdbof
			mv ppv_aux2.gdbof ppv_aux.gdbof
		fi	
		cat auxH.gdbof ppv_aux.gdbof > auxBouDump.foam.gdbof
		echo ");" >> auxBouDump.foam.gdbof
		echo "}" >> auxBouDump.foam.gdbof
		cat auxDump.foam.gdbof auxBouDump.foam.gdbof > aux.gdbof
		mv aux.gdbof auxDump.foam.gdbof
		rm ppv_aux.gdbof auxBouDump.foam.gdbof auxH.gdbof
	fi
fi
if [ $1 = "finalize" ];
then		
	echo "}" >> auxDump.foam.gdbof
	echo "\r" >> auxDump.foam.gdbof
	echo "// ************************************************************************* //" >> auxDump.foam.gdbof
	direc=`cat direc_name.gdbof`
	field=`cat field_name.gdbof`
	time=`cat time_aux.gdbof`
	counter=`ls $direc/$field* 2> /dev/null | sort -g | tail -n1 | cut -d '/' -f3 | cut -d '.' -f2 | cut -d '/' -f1`
	if [ -z "$counter"  ];
	then	
		counter=0
	else
		counter=`expr $counter + 1`
	fi
	mv auxDump.foam.gdbof $direc/$field.$counter.dump
	cd gdbOF_dump
	ln -s ../system system 2> /dev/null
	ln -s ../constant constant 2> /dev/null
	cd ..
	rm direc_name.gdbof
	echo $field.$counter.dump > field_name.gdbof
	echo "--------------------------------"
	echo "Field saved to gdbOF_dump/"$field.$counter.dump
	echo "--------------------------------"

fi
if [ $1 = "VTK" ];
then	
	sed -e 's/^/(/g' field_name.gdbof | sed -e 's/$/)/g' > field_name2.gdbof
	field=`cat field_name2.gdbof`
	time=`cat time_aux.gdbof`
	cd gdbOF_dump
	echo "Exporting to VTK..."
	foamToVTK -time $time -fields $field > foamToVTK.log  
	cd ..
fi
if [ $1 = "Paraview" ];
then		
	cd gdbOF_dump
	echo "Launching Paraview..."
	paraview --data=VTK/gdbOF_dump_0.vtk &
	cd ..
fi
if [ $1 = "clean" ];
then		
	rm -f *.gdbof 2> /dev/null
fi
