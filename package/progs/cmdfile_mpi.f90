!/ ------------------------------------------------------------------- /
      PROGRAM CMDFILE_MPI
!/
!/                  +-----------------------------------+
!/                  | WAVEWATCH III           NOAA/NCEP |
!/                  |           H. L. Tolman            |
!/                  |                        FORTRAN 90 |
!/                  | Last update :         10-Sep-2010 |
!/                  +-----------------------------------+
!/  Based on zeus codes by George Vandeberghe and Sam Trahan
!/
!/    26-Mar-2012 : Origination.
!/
!/    Copyright 2012 National Weather Service (NWS),
!/       National Oceanic and Atmospheric Administration.  All rights
!/       reserved.  Distributed as part of WAVEWATCH III. WAVEWATCH III
!/       is a trademark of the NWS.
!/       No unauthorized use without permission.
!/
!  1. Purpose :
!
!     Produce and API to run a set of commands from a command file on
!     the threads of a communicator, using MPI to distribute the work.
!
!  2. Method :
!
!  3. Parameters :
!
!  4. Subroutines used :
!
!     Standard MPI calls only.
!
!  5. Called by :
!
!     None, stand-alone program.
!
!  6. Error messages :
!
!     - See error escape locations at end of code.
!
!  7. Remarks :
!
!  8. Structure :
!
!     - See source code.
!
!  9. Switches :
!
!     - This is a true FORTRAN file without switches.
!
! 10. Source code :
!
!/ ------------------------------------------------------------------- /
!
      IMPLICIT NONE
!
      INCLUDE "mpif.h"
!/
!/ ------------------------------------------------------------------- /
!/ Local parameters
!/
      INTEGER                 :: IERR, NRANK, NSIZE, I
      CHARACTER(LEN=7)        :: FNAME = 'cmdfile'
      CHARACTER(LEN=126), ALLOCATABLE :: COMMANDS(:)
!/
!/ ------------------------------------------------------------------- /
!
! 0.  Initialization
!
      CALL MPI_INIT ( IERR )
      CALL MPI_COMM_RANK ( MPI_COMM_WORLD, NRANK, IERR )
      CALL MPI_COMM_SIZE ( MPI_COMM_WORLD, NSIZE, IERR ) 
!
      IF ( NRANK .EQ. 0 ) WRITE (*,900) FNAME, NSIZE
      CALL MPI_BARRIER ( MPI_COMM_WORLD, IERR )
!
!--- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
! 1.  Read data from input file
!
      OPEN ( 10, FILE=FNAME, FORM='formatted',STATUS='OLD', ERR=801, &
             IOSTAT=IERR ) 
      ALLOCATE ( COMMANDS(0:NSIZE-1) )
!
      DO I=0, NSIZE-1
        READ (10, '(A)', END=803, ERR=802 ) COMMANDS(I)
        END DO
!
!--- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
! 2.  Kick off command
!
      WRITE (*,920) NRANK, COMMANDS(NRANK)
      CALL SYSTEM ( COMMANDS(NRANK) ) 
!
!--- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!     Normal end of program
!
      GOTO 888
!
! Error scape locations
!
  801 CONTINUE
      IF (NRANK .EQ. 0 ) WRITE (*,1001) FNAME, IERR
      CALL MPI_BARRIER ( MPI_COMM_WORLD, IERR )
      CALL MPI_FINALIZE ( IERR )
      STOP 1001
!
  802 CONTINUE
      IF (NRANK .EQ. 0 ) WRITE (*,1002) FNAME, I, IERR
      CALL MPI_BARRIER ( MPI_COMM_WORLD, IERR )
      CALL MPI_FINALIZE ( IERR )
      STOP 1002
!
  803 CONTINUE
      IF (NRANK .EQ. 0 ) WRITE (*,1003) FNAME, I, IERR
      CALL MPI_BARRIER ( MPI_COMM_WORLD, IERR )
      CALL MPI_FINALIZE ( IERR )
      STOP 1003
!
  888 CONTINUE
!--- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!     Finalize program
!
      CALL MPI_BARRIER ( MPI_COMM_WORLD, IERR )
      CALL SYSTEM ( 'sleep 1')
      IF ( NRANK .EQ. 0 ) WRITE (*,999)
      CALL MPI_FINALIZE ( IERR )
!
! Formats
!
  900 FORMAT (/' cmdfile_mpi.x: use command file for parallel run'/   &
               ' ------------------------------------------------'/   &
               '     file name          : ',A/                        &
               '     number of commands : ',I6/)
!
  920 FORMAT (I3,':[',A,']')
!
  999 FORMAT (/' End of cmdfile_mpi.x'/)
!
 1001 FORMAT (/' *** ERROR IN OPENING ',A,' ***'/                     &
               '     IOSTAT =',I8)
 1002 FORMAT (/' *** ERROR IN READING ',A,' LINE',I4,' ***'/          &
               '     IOSTAT =',I8)
 1003 FORMAT (/' *** PREMATURE END OF ',A,' LINE',I4,' ***'/          &
               '     IOSTAT =',I8)
!
!/
!/ End of CMDFILE_MPI ------------------------------------------------ /
!/
      END PROGRAM CMDFILE_MPI
