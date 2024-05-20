#! python
#
# ----------------------------- CIMEC-INTEC ----------------------------------- 
# ------- Centro Internacional de Metodos Computacionales en Ingenieria -------
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
# 	Get the diag, upper, lower, upperAddr and lowerAddr arrays and generates and saves the sparse matrix
# ----------------------------------------------------------------------------------------

import sys
#import time
import string

try:  
	import cPickle as pickle  
except ImportError:  
	import pickle  

def cols_order(x,y):
	if x[1] > y[1]:
		return 1
	elif x[1] < y[1]:
		return -1
	elif x[0] > y[0]:
		return 1
	else:
		return -1

#now = time.time()

archi = open("fileAux.gdbof", "r")
lineas = archi.readlines()
upperAddr = string.split(lineas[0].replace('\\n"',''))
lowerAddr = string.split(lineas[1].replace('\\n"',''))
upper = string.split(lineas[2].replace('\\n"',''))
lower = string.split(lineas[3].replace('\\n"',''))
diag = string.split(lineas[4].replace('\\n"',''))
archi.close()

cells = len(diag)
sizeLowerAddr = len(lowerAddr)
sizeUpperAddr = len(upperAddr)

for i in range(sizeLowerAddr):
	lowerAddr[i] = int(lowerAddr[i])
	lower[i] = float(lower[i])

for i in range(sizeUpperAddr):
	upperAddr[i] = int(upperAddr[i])
	upper[i] = float(upper[i])

for i in range(cells):
	diag[i] = float(diag[i])

A = []

if len(sys.argv) == 2: #caso matrix completa
	start_i = 0
	start_j = 0
	stop_i = cells-1
	stop_j = cells-1
	nDiag = cells
	nUpper = sizeUpperAddr
	nLower = sizeLowerAddr
	nUpperLower = nLower + nUpper
else: #caso submatrix
	start_i = int(sys.argv[2])
	start_j = int(sys.argv[3])
	stop_i = int(sys.argv[4])
	stop_j = int(sys.argv[5])
	if start_i > stop_i:
		tmp_i = start_i
		start_i = stop_i
		stop_i = tmp_i
	if start_j > stop_j:
		tmp_j = start_j
		start_j = stop_j
		stop_j = tmp_j
	if start_i < 0 or stop_i < 0 or start_i >= cells or stop_i >= cells or start_j < 0 or stop_j < 0 or start_j >= cells or stop_j >= cells:
		print "i1, j1, i2, j2 are not in acceptable range: [0..%u, 0..%u].\n", cells-1, cells-1
		sys.exit()
	nDiag = min(stop_i-start_i+1,stop_j-start_j+1)
	nUpperLower = 0
	for k in range(sizeUpperAddr):
		i = lowerAddr[k];
		j = upperAddr[k];
		if (i >= start_i and i < stop_i+1) and (j >= start_j and j < stop_j+1):
			nUpperLower = nUpperLower + 1
		if (j >= start_i and j < stop_i+1) and (i >= start_j and i < stop_j+1):
			nUpperLower = nUpperLower + 1

headerLines = ["# name: OF\n","# type: sparse matrix\n", "# nnz: " + str(nDiag+nUpperLower) + "\n", "# rows: "+ str(stop_i-start_i+1) + "\n", "# columns: "+ str(stop_j-start_j+1)+ "\n"]
archi = open("header",'w')
archi.writelines(headerLines)
archi.close()

for i in range(nDiag+nUpperLower):
	A.append(range(3))	
	
index = 0

if stop_i - start_i < stop_j - start_j:
	for i in range(start_i, stop_i+1):
		A[index][0] = i-start_i+1
		A[index][1] = i-start_i+1
		A[index][2] = diag[i];
		index = index+1 
else:
	for i in range(start_j, stop_j+1):
		A[index][0] = i-start_i+1
		A[index][1] = i-start_i+1
		A[index][2] = diag[i];
		index = index+1 

for k in range(sizeUpperAddr):
	i = lowerAddr[k];
	j = upperAddr[k];
	if (i >= start_i and i < stop_i+1) and (j >= start_j and j < stop_j+1):
		A[index][0] = i-start_i+1	
		A[index][1] = j-start_j+1
		A[index][2] = upper[k]
		index = index + 1
	if (j >= start_i and j < stop_i+1) and (i >= start_j and i < stop_j+1):
		A[index][0] = j-start_j+1 			
		A[index][1] = i-start_i+1
		A[index][2] = lower[k]
		index = index + 1

A.sort(cols_order)

fileName = sys.argv[1]
archi = open(fileName, "w")
archi.write(str(A))
archi.close()	

#print "tiempo total: ",time.time()-now

