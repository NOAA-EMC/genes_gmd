#!/bin/sh
# ---------------------------------------------------------------------------- #
# run_make.sh  : Compile all auxiliary programs for GMD optimization package.  #
#                                                                              #
#                                      Author      : Hendrik L. Tolman         #
#                                                                              #
# 06-Nov-2008 : Origination.                                                   #
#               Adding compilers, routines or programs not documented.         #
# 26-Mar-2012 : Add MPI program option.                                        #
#                                                                              #
#    Copyright 2008-2012 National Weather Service (NWS),                       #
#       National Oceanic and Atmospheric Administration.  All rights           #
#       reserved.  Distributed as part of WAVEWATCH III. WAVEWATCH III is a    #
#       trademark of the NWS. No unauthorized use without permission.          #
#                                                                              #
# ---------------------------------------------------------------------------- #
# 1. Initialization

  set -e

  echo ' '
  echo 'run_make.sh :'
  echo '-------------'
  echo '   Compile programs for GMD optimization.'

  setup='.genes.env'
  mpi='yes'

# comp=ifort
# cmpi="ifort -lmpi"
# opt="-list -O3 -xSSE4.2 -ip"
## opt="-list -O3 -xSSE4.2 -ip -convert big_endian"
## opt="-list -O0 -g -traceback -check all -fpe0 -ftrapuv"
## opt="-list -O0 -g -traceback -check all -fpe0 -ftrapuv -convert big_endian"

  comp=pgf90
  cmpi=mpif90
  opt="-Mlist -fast"
## opt="-Mlist -fast -byteswapio"
## opt="-O0 -g -traceback -Mbounds -Mchkfpstk -Mchkptr -Mchkstk -Mlist"
## opt="-O0 -g -traceback -Mbounds -Mchkfpstk -Mchkptr -Mchkstk -Mlist -byteswapio"

# comp=xlf90
# cmpi=mpxlf90
# opt="-qsource -O3 -qnosave"

  subs='constants w3timemd w3dispmd w3arrymd random qtoolsmd cgaussmd'
  progs='process restart_co err_test err_tot err_par getmember'
  progs="$progs reseed initgen chckgen sortgen nextgen mapsgen"
  progs="$progs descent1 descent2 descent3 testerr"
  mpis='cmdfile_mpi'
  ext='.f90'

# ---------------------------------------------------------------------------- #
# 2. Test setup file

  if [ -f ~/$setup ]
  then
    echo "   Setup file $setup found."
    . ~/$setup
  else
    echo "   Setup file $setup NOT found (abort)."
    exit 1
  fi

  cd $genes_main/progs
  rm -f *.o *.lst *.mod

# ---------------------------------------------------------------------------- #
# 3. Compile subroutines and modules

  echo ' '
  echo '   Compiling subroutines :'
  echo '   -----------------------'

  for sub in $subs
  do
    echo "      processing $sub$ext ..."
    $comp -c $opt $sub$ext
  done

# ---------------------------------------------------------------------------- #
# 4. Compile programs

  echo ' '
  echo '   Compiling programs :'
  echo '   --------------------'

  for prog in $progs
  do
    echo "      processing $prog$ext ..."
    $comp $opt $prog$ext -o $prog.x *.o
    rm -f $prog.o
    mv $prog.x $genes_main/exe/.
  done

# ---------------------------------------------------------------------------- #
# 5. Compile MPI programs

  if [ "$mpi" = 'yes' ]
  then
    echo ' '
    echo '   Compiling MPI programs :'
    echo '   ------------------------'

    for prog in $mpis
    do
      echo "      processing $prog$ext ..."
      $cmpi $opt $prog$ext -o $prog.x *.o
      rm -f $prog.o
      mv $prog.x $genes_main/exe/.
    done
  fi

# ---------------------------------------------------------------------------- #
# 6. End of script

  echo ' '
  echo 'End of run_make.sh' 

# End of run_make.sh --------------------------------------------------------- #
