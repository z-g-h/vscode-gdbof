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
#   Created By:
#   J.M. Gimenez(1), S.Marquez Damian(2), N. Nigro(2)
#
#   (1)FICH - UNL - Santa Fe, Argentina
#   (2)CIMEC (INTEC-UNL-CONICET), Santa Fe, Argentina
#   
#   Contact: jmarcelogimenez@gmail.com (Subject: gdbOF)
#

define pSurfaceValue
	set $type = $arg0.typeName._M_dataplus._M_p
	if $arg1
		set $patch = $arg0.boundaryField_.ptrs_.v_[$arg2]
		if($patch.size_ > 0)
			printf "boundary Face: \n"
			if $_streq($type,"surfaceScalarField")
				p *($patch.v_+$arg3)
			else
				p ($patch.v_+$arg3).v_
			end
		else
			printf "empty Face \n"
		end
	else
		printf "internal Face: \n"
		if $_streq($type,"surfaceScalarField")
			p *($arg0.v_+$arg2)
		else
			p $arg0.v_+$arg2
		end
	end
end
