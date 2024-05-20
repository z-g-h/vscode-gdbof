#
# Hidden pInternalValues OF
#

define pInternalValuesh
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
		end
	end
end


#
# Hidden pPatchValues OF
#

define pPatchValuesh
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
			if $size > 0
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
				end
			end
		end
	end
end
