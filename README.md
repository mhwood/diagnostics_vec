# diagnostics_ob
Development space for a new diagnostics package for the MITgcm

## Known issues:
1. MPI must be used because the code is dependent on MPI_SEND and MPI_RECV
2. The current lookup table function does NOT account for nSx and nSy 
    - i.e. only ONE tile can be used for each process (but multiple processes may be employed)
