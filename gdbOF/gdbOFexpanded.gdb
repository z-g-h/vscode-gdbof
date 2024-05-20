#         
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
#   gdbOF - 1.0
#
#   The new GDB commands:                                                         
# 	    are entirely non instrumental                                             
# 	    do not depend on any "inline"(s) - e.g. size(), [], etc
#       are extremely tolerant to debugger settings
#                                                                                 
#   This file should be "included" in .gdbinit as following:
#   source gdfOF.gdb or just paste it into your .gdbinit file
#
#
#   Make sure your debugger supports $argc
#
#   Created By:
#   J.M. Gimenez(1), S.Marquez Damian(1), N. Nigro(1)
#
#   (1)CIMEC (INTEC-UNL-CONICET), Santa Fe, Argentina
#
#   contact: jmarcelogimenez@gmail.com
#
#   Inspired by work of Dan Marinescu (STL)
#   	
#   
#   Contact: jmarcelogimenez@gmail.com (Subject: gdbOF)
#

#comandos default:
set pagination off
set print elements 0
set print repeats 0


#
# pPatchList OF
#

define pPatchList
	if $argc == 0
		printf "Use \"pPatchList <objeto> \"\n"
	else
		set $len = $arg0.boundaryField_.ptrs_.size_
		set $v = $arg0.boundaryField_.ptrs_.v_
		set $i = 0
		printf "PatchName   -->   Index to Use \n"
		while $i < $len
			printf "%s    -->   %u\n", ((**($v+$i)).patch_.name()._M_dataplus._M_p), $i			
			set $i++		
		end

	end
end

document pPatchList
	Prints a list with the patch name and its ID
	Syntax: pPatchList/ppl <GeometricField>
	Examples:
	pPatchList T
end

#
# pInternalValues OF
#

define pInternalValues
	if $argc > 2 || $argc == 0
		printf "Use \"pInternalValues <objeto> [<file>]\"\n"
	else
		set $size = $arg0.size_
		set $type = $arg0.typeName._M_dataplus._M_p
		set $style = 0
		if $argc == 2
			set logging file $arg1
			set logging redirect on
			set logging on
		end

		set $start = 0
		set $end = $size
		if $_streq($type,"volScalarField")  || $_streq($type,"surfaceScalarField") 
			p *($arg0.v_+$start)@($end-$start)
		else
			if $_streq($type,"volVectorField")  || $_streq($type,"surfaceVectorField") 
				p ($arg0.v_+$start).v_@($end-$start)
				set $style = 1
			else
				if $_streq($type,"volSymmTensorField")  || $_streq($type,"surfaceSymmTensorField") 
					p ($arg0.v_+$start).v_@($end-$start)
					set $style = 2
				else
					if $_streq($type,"volTensorField")  || $_streq($type,"surfaceTensorField") 
						p ($arg0.v_+$start).v_@($end-$start)
						set $style = 3
					end
				end
			end
		end 
		if $argc == 2
			set logging redirect off
			set logging off
			if $style == 0 
				shell sh $GDBOFPATH/gdbOF/scalarField2octave.sh $arg1
			else
				if $style == 1
					shell sh $GDBOFPATH/gdbOF/vectorField2octave.sh $arg1
				else
					if $style == 2
						shell sh $GDBOFPATH/gdbOF/symmTensorField2octave.sh $arg1
					else 
						if $style == 3
							shell sh $GDBOFPATH/gdbOF/tensorField2octave.sh $arg1
						end
					end
				end			
			end
			printf "Saved correctly!\n"
		end
	end
end

document pInternalValues
	Prints the field values on the internal mesh
	Syntax: pInternalValues/piv <GeometricField> [<filename>]
	Examples:
	pInternalValues T: returns the values of the internal mesh on Geometric Field T
	pInternalValues T T.txt: prints the values of the internal mesh on Geometric Field T in the specified file
end

#
# pPatchValues OF
#

define pPatchValues
	if $argc < 2 || $argc > 3
		printf "Use \"pPatchValues <objeto> <index>  [<file>]\"\n"
	else
		if $arg1 < 0 || $arg1 >= $arg0.boundaryField_.ptrs_.size_
			printf "Error en el indice \n"
		else
			set $patch = $arg0.boundaryField_.ptrs_.v_[$arg1]
			set $size = $patch.size_
			set $type = $arg0.typeName._M_dataplus._M_p
			set $style = 0
			if $size == 0
				printf "Empty Condition, no values \n"
			else
				if $argc == 3
					set logging file $arg2
					set logging redirect on
					set logging on
				end
				set $start = 0
				set $end = $size
				if $_streq($type,"volScalarField")  || $_streq($type,"surfaceScalarField") 
					p *($patch.v_+$start)@($end-$start)
				else
					if $_streq($type,"volVectorField")  || $_streq($type,"surfaceVectorField") 
						p ($patch.v_+$start).v_@($end-$start)
						set $style = 1
					else
						if $_streq($type,"volSymmTensorField")  || $_streq($type,"surfaceSymmTensorField") 
							p ($patch.v_+$start).v_@($end-$start)
							set $style = 2
						else
							if $_streq($type,"volTensorField")  || $_streq($type,"surfaceTensorField") 
								p ($patch.v_+$start).v_@($end-$start)
								set $style = 3
							end
						end
					end
				end
				if $argc == 3
					set logging redirect off
					set logging off
					if $style == 0 
						shell sh $GDBOFPATH/gdbOF/scalarField2octave.sh $arg2
					else
						if $style == 1
							shell sh $GDBOFPATH/gdbOF/vectorField2octave.sh $arg2
						else
							if $style == 2
								shell sh $GDBOFPATH/gdbOF/symmTensorField2octave.sh $arg2
							else 
								if $style == 3
									shell sh $GDBOFPATH/gdbOF/tensorField2octave.sh $arg2
								end
							end
						end
					end
					printf "Saved correctly!\n"
				end
			end
		end
	end
end

document pPatchValues
	Prints the field values on the selected patch
	Syntax: pPatchValues/ppv <GeometricField> <indexPatch> [<filename>]
	Examples:
	pPatchValues T 0 : returns the values of the patch[0] in Geometric Field T
	pPatchValues T 0 T_0.txt: prints the values of the patch[0] in Geometric Field T on T_0.txt file
end


#
# fvMatrixFull OF 
#

define pfvMatrixFull
	if $argc != 2 && $argc != 6
		printf "Use \"pfvmatrixfull <objeto> <file> [<row from> <col from><row to> <col to>]\"\n"
	else
		shell rm -f *.gdbof
		set logging file fileAux.gdbof
		set logging redirect on
		set logging on
		p *$arg0.lduMesh_.lduAddr().upperAddr().v_@$arg0.lduMesh_.lduAddr().upperAddr().size_	
		p *$arg0.lduMesh_.lduAddr().lowerAddr().v_@$arg0.lduMesh_.lduAddr().lowerAddr().size_
		if $arg0.upperPtr_ != 0x0		
			p *$arg0.upperPtr_.v_@$arg0.upperPtr_.size_	
		else
			p *$arg0.lowerPtr_.v_@$arg0.lowerPtr_.size_	
		end
		if $arg0.lowerPtr_ != 0x0		
			p *$arg0.lowerPtr_.v_@$arg0.lowerPtr_.size_	
		else
			p *$arg0.upperPtr_.v_@$arg0.upperPtr_.size_	
		end
		p *$arg0.diagPtr_.v_@$arg0.diagPtr_.size_
		set logging redirect off
		set logging off
		set $sizeDiag = $arg0.diagPtr_.size_
		shell sh  $GDBOFPATH/gdbOF/gdb2python.sh fileAux.gdbof
		if $argc == 2
			shell python $GDBOFPATH/gdbOF/fvMatrixFull.py $arg1
		else
			#no puedo aplicar control porque no paso como parametro variables globales aca			
			#controlar en python
			shell python $GDBOFPATH/gdbOF/fvMatrixFull.py $arg1 $arg2 $arg3 $arg4 $arg5
		end
		shell sh $GDBOFPATH/gdbOF/python2gdb.sh $arg1
		#shell cat $arg1	
		shell sh $GDBOFPATH/gdbOF/matrix2octave.sh $arg1
		printf "\nSaved correctly!\n"
		shell rm fileAux.gdbof
	end
end

document pfvMatrixFull
	Print in a file the full fvMatrix to load in octave/matlab
	Syntax: pfvMatrixFull <fvMatrix> <file name> <i1> <j1> <i2> <j2>
	Note: i1, i2, j1 and j2 must be in acceptable range [0..sizeDiag, 0..sizeDiag].
	Examples:
	pfvMatrixFull v matrix.txt - Prints all matrix content in the specified file
	pfvMatrixFull v matrix.txt 0 1 5 6 - Prints elements in the submatrix [0][1] to [5][6] in the specified file
end

#
# fvMatrixSparse OF 
#

define pfvMatrixSparse
	if $argc != 2 && $argc != 6
		printf "Use \"pfvmatrixsparse <objeto> <file> [<row from> <col from><row to> <col to>]\"\n"
	else
		shell rm -f fileAux.gdbof
		set logging file fileAux.gdbof
		set logging redirect on
		set logging on
		p *$arg0.lduMesh_.lduAddr().upperAddr().v_@$arg0.lduMesh_.lduAddr().upperAddr().size_	
		p *$arg0.lduMesh_.lduAddr().lowerAddr().v_@$arg0.lduMesh_.lduAddr().lowerAddr().size_
		if $arg0.upperPtr_ != 0x0		
			p *$arg0.upperPtr_.v_@$arg0.upperPtr_.size_	
		else
			p *$arg0.lowerPtr_.v_@$arg0.lowerPtr_.size_	
		end
		if $arg0.lowerPtr_ != 0x0		
			p *$arg0.lowerPtr_.v_@$arg0.lowerPtr_.size_	
		else
			p *$arg0.upperPtr_.v_@$arg0.upperPtr_.size_	
		end
		p *$arg0.diagPtr_.v_@$arg0.diagPtr_.size_
		set logging redirect off
		set logging off
		set $sizeDiag = $arg0.diagPtr_.size_
		shell sh  $GDBOFPATH/gdbOF/gdb2python.sh fileAux.gdbof
		if $argc == 2
			shell python $GDBOFPATH/gdbOF/fvMatrixSparse.py $arg1
		else
			#no puedo aplicar control porque no paso como parametro variables globales aca			
			#controlar en python
			shell python $GDBOFPATH/gdbOF/fvMatrixSparse.py $arg1 $arg2 $arg3 $arg4 $arg5
		end
		shell sh $GDBOFPATH/gdbOF/python2gdb.sh $arg1
		#shell cat $arg1	
		shell sh $GDBOFPATH/gdbOF/matrix2octave.sh $arg1
		shell sh $GDBOFPATH/gdbOF/appendHeaderSparse.sh $arg1
		printf "\nSaved correctly!\n"
		shell rm -f fileAux.gdbof header
	end
end

document pfvMatrixSparse
	Print in a file the full fvMatrix to load in octave/matlab in sparse format
	Syntax: pfvmatrixsparse <fvMatrix> <file name> [<i1> <j1> <i2> <j2>]
	Note: i1, i2, j1 and j2 must be in acceptable range [0..sizeDiag, 0..sizeDiag].
	Examples:
	pfvMatrixSparse v matrix.txt - Prints all matrix content in the specified file
	pfvMatrixSparse v matrix.txt 0 1 5 6 - Prints elements in the submatrix [0][1] to [5][6] in the specified file
end

#
# pInternalValuesLimits OF
#

define pInternalValuesLimits
	if $argc != 3 && $argc != 4
		printf "Use \"pinternalvalues <objeto> <start> <end> [<file>]\"\n"
	else
		set $size = $arg0.size_
		set $type = $arg0.typeName._M_dataplus._M_p
		set $style = 0
		set $start = $arg1
		set $end = $arg2 + 1
		if $end < $start
			set $temp = $end
			set $end = $start
			set $start = $end
		end
		if $start < 0 || $start >= $size || $end < 0 || $end > $size
			printf "start, end are not in acceptable range: [0..%u].\n", $size-1
		else
			if $argc == 4
				set logging file $arg3
				set logging redirect on
				set logging on
			end
			if $_streq($type,"volScalarField")  || $_streq($type,"surfaceScalarField") 
				p *($arg0.v_+$start)@($end-$start)
			else
				if $_streq($type,"volVectorField")  || $_streq($type,"surfaceVectorField") 
					p ($arg0.v_+$start).v_@($end-$start)
					set $style = 1
				else
					if $_streq($type,"volSymmTensorField")  || $_streq($type,"surfaceSymmTensorField") 
						p ($arg0.v_+$start).v_@($end-$start)
						set $style = 2
					else
						if $_streq($type,"volTensorField")  || $_streq($type,"surfaceTensorField") 
							p ($arg0.v_+$start).v_@($end-$start)
							set $style = 3
						end
					end
				end
			end 
			if $argc == 4
				set logging redirect off
				set logging off
				if $style == 0 
					shell sh $GDBOFPATH/gdbOF/scalarField2octave.sh $arg3
				else
					if $style == 1
						shell sh $GDBOFPATH/gdbOF/vectorField2octave.sh $arg3
					else
						if $style == 2
							shell sh $GDBOFPATH/gdbOF/symmTensorField2octave.sh $arg3
						else 
							if $style == 3
								shell sh $GDBOFPATH/gdbOF/tensorField2octave.sh $arg3
							end
						end
					end			
				end
				printf "Saved correctly!\n"
			end
		end
	end
end

document pInternalValuesLimits
	Prints the values of the internal mesh in the specified range of cells
	Syntax: pInternalValuesLimits <GeometricField> <index_cell_start> <index_cell_end> [<filename>]
	Examples:
	pInternalValuesLimits T 0 3: returns the values of the internal mesh on Geometric Field T for the cells 0,1,2 and 3
	pInternalValuesLimits T 0 3 T.txt: prints the values of the internal mesh on Geometric Field T in the specified file for the cells 0,1,2 and 3
end

#
# pPatchValuesLimits OF
#

define pPatchValuesLimits
	if $argc != 4 && $argc != 5
		printf "Use \"ppatchvalues <objeto> <index> <start> <end> [<file>]\"\n"
	else
		if $arg1 < 0 || $arg1 >= $arg0.boundaryField_.ptrs_.size_
			printf "Error en el indice \n"
		else
			set $patch = $arg0.boundaryField_.ptrs_.v_[$arg1]
			set $size = $patch.size_
			set $type = $arg0.typeName._M_dataplus._M_p
			set $style = 0
			if $size == 0
				printf "Empty Condition, no values \n"
			else
				set $start = $arg2
				set $end = $arg3 + 1
				if $end < $start
					set $temp = $end
					set $end = $start
					set $start = $end
				end
				if $start < 0 || $start >= $size || $end < 0 || $end > $size
					printf "start, end are not in acceptable range: [0..%u].\n", $size-1
				else
					if $argc == 5
						set logging file $arg4
						set logging redirect on
						set logging on
					end
					if $_streq($type,"volScalarField")  || $_streq($type,"surfaceScalarField") 
						p *($patch.v_+$start)@($end-$start)
					else
						if $_streq($type,"volVectorField")  || $_streq($type,"surfaceVectorField") 
							p ($patch.v_+$start).v_@($end-$start)
							set $style = 1
						else
							if $_streq($type,"volSymmTensorField")  || $_streq($type,"surfaceSymmTensorField") 
								p ($patch.v_+$start).v_@($end-$start)
								set $style = 2
							else
								if $_streq($type,"volTensorField")  || $_streq($type,"surfaceTensorField") 
									p ($patch.v_+$start).v_@($end-$start)
									set $style = 3
								end
							end
						end
					end
					if $argc == 5
						set logging redirect off
						set logging off
						if $style == 0 
							shell sh $GDBOFPATH/gdbOF/scalarField2octave.sh $arg4
						else
							if $style == 1
								shell sh $GDBOFPATH/gdbOF/vectorField2octave.sh $arg4
							else
								if $style == 2
									shell sh $GDBOFPATH/gdbOF/symmTensorField2octave.sh $arg4
								else 
									if $style == 3
										shell sh $GDBOFPATH/gdbOF/tensorField2octave.sh $arg4
									end
								end
							end
						end
						printf "Saved correctly!\n"
					end
				end
			end
		end
	end
end

document pPatchValuesLimits
	Prints the values of the patch in the specified cells
	Syntax: pPatchValuesLimits <GeometricField> <indexPatch> <index_cell_start> <index_cell_end>
	Examples:
	pPatchValuesLimits T 0 2 3: returns the values of the patch[0] in Geometric Field T for the cells 2 and 3
	pPatchValuesLimits T 0 2 3 T_0.txt: prints the values of the patch[0] in Geometric Field T on T_0.txt file  for the cells 2 and 3
end


#
# -------- START APPEND 09/06/2010 -------------
#

#
# pFindCell OF
#

define pFindCell
	if $argc != 3
		printf "Use \"pfindcell <x> <y> <z>\"\n"
	else
		shell findCell $arg0 $arg1 $arg2 > aux
		shell sh  $GDBOFPATH/gdbOF/printTail.sh 3
		shell rm aux
	end
end

document pFindCell
	Prints the nearest cell centroid index and the cell centroid index that contains the point specified
	Syntax: pfindcell <x> <y> <z>
	Examples:
	pfindcell 0.5 0.2 0.3: for the point [0.5,0.2,0.3]
end

#
# pFindFace OF
#

define pFindFace
	if $argc != 3
		printf "Use \"pfindface <x> <y> <z>\"\n"
	else
		shell findFace $arg0 $arg1 $arg2 > aux
		shell sh  $GDBOFPATH/gdbOF/printTail.sh 3
		shell rm aux
	end
end

document pFindFace
	Prints the nearest patchID from the point, and the nearest faceID in this patch.
	Syntax: pfindface <x> <y> <z>
	Examples:
	pfindface 0.5 0.2 0.3: for the point [0.5,0.2,0.3]
end

#
# pSurfaceValues OF
#

define pSurfaceValues
	if $argc != 2
		printf "Use \"psurfacevalues <surface*Field> <cellID>\"\n"
	else
		set $type = $arg0.typeName._M_dataplus._M_p
		if($_streq($type,"surfaceScalarField")  || $_streq($type,"surfaceVectorField") )
			shell findFacesCell $arg1 > aux
			set $nfaces = (*(mesh.cells().v_ + $arg1)).size_
			#printf "numero de caras en la celda: %d" , $nfaces

			shell sh $GDBOFPATH/gdbOF/files2surfaceValue.sh

			set $i=0
			while $i < $nfaces				

				shell rm file.gdbof

				set logging file file.gdbof
				set logging redirect on
				set logging on
				printf "data%d.dat", $i
				set logging redirect off
				set logging off

				shell sh $GDBOFPATH/gdbOF/makeMacroTemp.sh $arg0
				source /home/of1812/OpenFOAM/gdbof/gdbOF/macroTemp.gdb
				psurfacevalue
				set $i = $i+1

			end

			shell rm data*.dat $GDBOFPATH/gdbOF/macroTemp.gdb aux

		else
			printf "El campo debe ser un \"surface*Field\"\n"
		end


	end
end

document pSurfaceValues
	Prints the values of the faces in the cell
	Syntax: pSurfaceValues <surface*Field> <cellID>
	Examples:
	pSurfaceValues phi 0 : returns the values of phi in the faces in the cellID=0
end

#
# -------- END APPEND 09/06/2010 -------------
#

#
# -------- START APPEND 16/06/2011 -------------
#

#aliases

#
# ppl OF
#

define pPl
	if $argc != 1
		printf "Use \"ppl <objeto> \"\n"
	else
		ppatchlist $arg0
	end
end

document pPl
	Alias to call ppatchlist
	Syntax: ppl <GeometricField>
	Examples:
	ppl T
end

#
# piv OF
#

define pIv
	if $argc > 2 || $argc == 0
		printf "Use \"piv <objeto> [<file>]\"\n"
	else
		if $argc==1
			pinternalvalues $arg0 
		else
			pinternalvalues $arg0 $arg1
		end
	end
end

document pIv
	Alias to call pinternalvalues
	Syntax: piv <GeometricField> [<filename>]
	Examples:
	piv T: returns the values of the internal mesh on Geometric Field T
	piv T T.txt: prints the values of the internal mesh on Geometric Field T in the specified file
end

#
# ppv OF
#
define pPv
	if $argc < 2 || $argc > 3
		printf "Use \"ppv <objeto> <index>  [<file>]\"\n"
	else
		if $argc==2
			ppatchvalues $arg0 $arg1
		else 
			ppatchvalues $arg0 $arg1 $arg2
		end
	end
end

document pPv
	Alias to call pPatchValues
	Syntax:  ppv <GeometricField> <indexPatch>
	Examples:
	ppv T 0 : returns the values of the patch[0] in Geometric Field T
	ppv T 0 T_0.txt: prints the values of the patch[0] in Geometric Field T on T_0.txt file
end


#
# pexportfoamformat OF
#
define pExportFoamFormat
	if $argc < 1 || $argc > 3
		printf "Use \"pexportfoamformat <objeto> [VTK [Paraview]]\"\n"
	else
		shell rm -f *.gdbof
		set $type = $arg0.typeName._M_dataplus._M_p
		set $field="none"
		if $_streq($type,"volScalarField") 
			set $field="scalar"
		end
		if $_streq($type,"volVectorField") 
			set $field="vector"
		end
		if $_streq($type,"volSymmTensorField") 
			set $field="symmTensor"
		end
		if $_streq($type,"volTensorField") 
			set $field="tensor"
		end
		if $_streq($field,"none") != 0
			up-silently 20
			set $time = runTime.timeName(runTime.value_)._M_dataplus._M_p
			down-silently 20
			if $time
				set logging file time_aux.gdbof
				set logging redirect on
				set logging on
				p $time
				set logging redirect off
				set logging off
				
				set logging file dim_aux.gdbof
				set logging redirect on
				set logging on
				p $arg0.dimensions_.exponents_
				set logging redirect off
				set logging off		
				shell sh $GDBOFPATH/gdbOF/manageDumpDirectory.sh include_dim

				set logging file class_aux.gdbof
				set logging redirect on
				set logging on
				p $arg0.typeName._M_dataplus._M_p
				set logging redirect off
				set logging off		
				shell sh $GDBOFPATH/gdbOF/manageDumpDirectory.sh include_class

				set logging file object_aux.gdbof
				set logging redirect on
				set logging on
				p $arg0.name_._M_dataplus._M_p
				set logging redirect off
				set logging off		
				shell sh $GDBOFPATH/gdbOF/manageDumpDirectory.sh include_object

				shell sh $GDBOFPATH/gdbOF/manageDumpDirectory.sh include_version

				printf "Including internal field...\n"
				pinternalvaluesh $arg0 piv_aux.gdbof
				if $_streq($field,"scalar") 
					shell sh $GDBOFPATH/gdbOF/manageDumpDirectory.sh include_iv scalar
				end
				if $_streq($field,"vector") 
					shell sh $GDBOFPATH/gdbOF/manageDumpDirectory.sh include_iv vector
				end
				if $_streq($field,"symmTensor") 
					shell sh $GDBOFPATH/gdbOF/manageDumpDirectory.sh include_iv symmTensor
				end
				if $_streq($field,"tensor") 
					shell sh $GDBOFPATH/gdbOF/manageDumpDirectory.sh include_iv tensor
				end
				
				set $len = $arg0.boundaryField_.ptrs_.size_
				set $v = $arg0.boundaryField_.ptrs_.v_
				set $i = 0
				printf "Including boundary field(s)...\n"
				while $i < $len
					#printf "Including %s boundary field\n", ((**($arg0.boundaryField_.ptrs_.v_+$i)).patch_.name()._M_dataplus._M_p)
					printf "%s\n", ((**($arg0.boundaryField_.ptrs_.v_+$i)).patch_.name()._M_dataplus._M_p)
					pPatchValuesh $arg0 $i ppv_aux.gdbof
					set logging file bouName_aux.gdbof
					set logging redirect on
					set logging on
					print ((**($arg0.boundaryField_.ptrs_.v_+$i)).patch_.name()._M_dataplus._M_p)
					set logging redirect off
					set logging off

					set logging file bouType_aux.gdbof
					set logging redirect on
					set logging on
					print ((**($arg0.boundaryField_.ptrs_.v_+$i)).type()._M_dataplus._M_p)
					set logging redirect off
					set logging off

#					set $patchtype = ((**($arg0.boundaryField_.ptrs_.v_+$i)).type()._M_dataplus._M_p)
#					if $_streq($patchtype,"empty")==0 || $_streq($patchtype,"zeroGradient")==0 || $_streq($patchtype,"wedge")==0
#					end

					if $_streq($field,"scalar") 
						shell sh $GDBOFPATH/gdbOF/manageDumpDirectory.sh include_pv scalar
					end
					if $_streq($field,"vector") 
						shell sh $GDBOFPATH/gdbOF/manageDumpDirectory.sh include_pv vector
					end
					if $_streq($field,"symmTensor") 
						shell sh $GDBOFPATH/gdbOF/manageDumpDirectory.sh include_pv symmTensor
					end
					if $_streq($field,"tensor") 
						shell sh $GDBOFPATH/gdbOF/manageDumpDirectory.sh include_pv tensor
					end
					set $i = $i+1
				end
				shell sh $GDBOFPATH/gdbOF/manageDumpDirectory.sh make_dirs

				shell sh $GDBOFPATH/gdbOF/manageDumpDirectory.sh finalize

				if $argc > 1
					shell sh $GDBOFPATH/gdbOF/manageDumpDirectory.sh $arg1
					#if $_streq($arg1,"VTK") != 0
					#	printf "Second argument is invalid ... not exported to VTK"
					#end
				end
				if $argc > 2
					shell sh $GDBOFPATH/gdbOF/manageDumpDirectory.sh $arg2
					#if $_streq($arg2,"Paraview") != 0
					#	printf "Third argument is invalid ... not opened paraview"
					#end
				end
				shell sh $GDBOFPATH/gdbOF/manageDumpDirectory.sh clean							
			else
				printf "ERROR: runTime object doesn't exists"
			end
		else
			printf "ERROR: $arg0 must be a vol*Field"
		end
	end
end

document pExportFoamFormat
	Export vol*Field in Foam format. It allows converting it to VTK and opening with Paraview
	Syntax:  pexportformatfoam <GeometricField> [VTK [Paraview] ]
	Examples:
	pexportformatfoam T: exports the geometricField to gdbOF_dump folder (in the time step folder)
 	pexportformatfoam T VTK: exports the geometricField to gdbOF_dump folder (in the time step folder) and export it to VTK format
	pexportformatfoam T VTK Paraview: exports the geometricField to gdbOF_dump folder (in the time step folder), export it to VTK format and opens Paraview
end

#
# -------- END APPEND 16/06/2011 -------------
#
source /home/of1812/OpenFOAM/gdbof/gdbOF/hiddenFunctions.gdb


#
# -------- START APPEND 09/11/2011 -------------
#

#
# pFieldValues -> solo funciona para scalar (no tengo manera de conocer de que tipo es la lista)
#

define pFieldValues
	if $argc > 2 || $argc == 0
		printf "Use \"pFieldValues <objeto> [<file>]\"\n"
	else
		set $size = $arg0.size_
		if $argc == 2
			set logging file $arg1
			set logging redirect on
			set logging on
		end

		set $start = 0
		set $end = $size
		p *($arg0.v_+$start)@($end-$start)
		
		if $argc == 2
			set logging redirect off
			set logging off
			shell sh $GDBOFPATH/gdbOF/scalarField2octave.sh $arg1
			printf "Saved correctly!\n"
		end
	end
end

document pFieldValues
	Prints the field values without associated mesh (Every Field is considered like scalarField)
	Syntax: pFieldValues/piv <Field> [<filename>]
	Examples:
	pFieldValues S: returns the values of the field
	pFieldValues S S.txt: prints the values of the field in the specified file
end


#
# pFieldValuesLimits OF
#

define pFieldValuesLimits
	if $argc != 3 && $argc != 4
		printf "Use \"pFieldValuesLimits <objeto> <start> <end> [<file>]\"\n"
	else
		set $size = $arg0.size_
		set $start = $arg1
		set $end = $arg2 + 1
		if $end < $start
			set $temp = $end
			set $end = $start
			set $start = $end
		end
		if $start < 0 || $start >= $size || $end < 0 || $end > $size
			printf "start, end are not in acceptable range: [0..%u].\n", $size-1
		else
			if $argc == 4
				set logging file $arg3
				set logging redirect on
				set logging on
			end
			p *($arg0.v_+$start)@($end-$start)
			if $argc == 4
				set logging redirect off
				set logging off
				shell sh $GDBOFPATH/gdbOF/scalarField2octave.sh $arg3
				printf "Saved correctly!\n"
			end
		end
	end
end

document pFieldValuesLimits
	Prints the values of the field without associated mesh in the specified range of cells (Every Field is considered like scalarField)
	Syntax: pFieldValuesLimits <Field> <index_start> <index_end> [<filename>]
	Examples:
	pFieldValuesLimits T 0 3: returns the values of the field T for the cells 0,1,2 and 3
	pInternalValuesLimits T 0 3 T.txt: prints the values of the field T in the specified file for the cells 0,1,2 and 3
end

#
# -------- END APPEND 09/11/2011 -------------
#

#
# -------- START APPEND 02/04/2014 -------------
#

#
# pName OF
#

define pName
        if $argc == 0
                printf "Use \"pName <object> \"\n"
        else
                printf "%s\n", ($arg0.name()._M_dataplus._M_p)
        end
end

document pName
        Prints the name of the object
        Syntax: pName <object>
        Examples:
        pName alpha
end

#
# -------- END APPEND 02/04/2014 -------------
#
