
pkg/diagnostics_vec – Targeted Output
=====================================

Introduction
------------

This section of the documentation describes the diagnostics_vec package
(:filelink:`pkg/diagnostics_vec`)
available within MITgcm. This package is designed to output model diagnostics
on subsets of the domain i.e. along vectors. The usage mirrors the usage of the
diagnostics package in that the user must specific the exact diagnostics 
information required for an experiement. The main difference is that for 
for the diagnostics_vec package, the user must also supply a mask field which
delineates where the requested diagnostics will be sampled. There are two types of masks implemented in diagnostics_vec: vectors and surfaces. Vector masks are designed to diagnose prognostic and tracer variables at a number of vertical levels. Surface masks are designed to diagnose variables such as external forcing variables, but may also access prognostic and tracer variables in vertical level 1. Information about which variables are available, and how to generate the masks files is provided in the Usage Notes below. 

Equations
---------

Not relevant.

Key Subroutines and Parameters
------------------------------

The diagnostics_vec package rests on three fundamental routines: 

1. ``identify_vec_points`` (defined within :filelink:`diagnostics_vec_init_fixed.F <pkg/diagnostics_vec/diagnostics_vec_init_fixed.F>`) 

2. ``set_subfields`` (defined within :filelink:`diagnostics_vec_prepare_subfield.F <pkg/diagnostics_vec/diagnostics_vec_prepare_subfield.F>`.) 

3. ``vec_master_proc_tasks`` (defined within :filelink:`diagnostics_vec_output.F <pkg/diagnostics_vec/diagnostics_vec_output.F>`.) 

Note that these routines are for the vector masks, and there are corresponding routines for surface masks.

:filelink:`identify_vec_points <pkg/diagnostics_vec/diagnostics_vec_init_fixed.F>`:
This is the main user interface routine to the
diagnostics package. This routine will increment the specified
diagnostic quantity with a field sent through the argument list.

The primary function of the ``identify_vec_points`` routine is fill in three key
reference lists that are used at each time step to organize and collect
requested diagnostics at specific locations:  

::

   vec_sub_local_ij(nVEC_mask, 4, (sNx+sNy)*(sNx*sNy))
   vec_numPnts_allproc(nVEC_mask, nPx*nPy)
   vec_mask_index_list(nVEC_mask, nPx*nPy, (sNx+sNy)*(sNx*sNy))


The first list, ``vec_sub_local_ij``, keeps a sequential record of the locations of each
model diagnostic on each tile. For example, the 11th point along the 7th vector mask is found
at 

::

   i = vec_sub_local_ij(7, 1, 11)
   j = vec_sub_local_ij(7, 2, 11)


on subtile 

::

   bi = vec_sub_local_ij(7, 3, 11)
   bj = vec_sub_local_ij(7, 4, 11)


This list is used at each timestep to collect the requested diagnostics at the mask-defined locations without looping through the entire domain. 

The second list, ``vec_numPnts_allproc``, keeps a record of the number of mask points for each processing tile, and is accessed at each timestep, as described below. By looping over only the known number of points, a loopover the entire domain is avoided.

:filelink:`set_subfields <pkg/diagnostics_vec/diagnostics_vec_prepare_subfield.F>`:
The ``set_subfields`` routine collects the requested model diagnostics for each mask provided. This step uses the ``vec_sub_local_ij`` and ``vec_numPnts_allproc`` references created above to organize the desired diagnostics. At each timestep (as seen by ``do_the_model_io.F``), the routine loops through the number of points the processing tile contains (accessed from ``vec_numPnts_allproc``), get the coordinates within the subtile (accessed from ``vec_sub_local_ij``) and stores these values in an ordered list. These values continue to be stored and incremented until the output time is reached.


:filelink:`vec_master_proc_tasks <pkg/diagnostics_vec/diagnostics_vec_output.F>`:
This is the main routine which prepares the variables for output and stores them in a file. The routine starts with the main processing node storing its values (if it has any) in a global array. Here, the locations of the points within the output array are given by the ``vec_mask_index_list`` array. If MPI is not used, then then this processing node will already have all of the information it needs for output. If MPI is used, then the main processing node needs to collect the information from all of the other nodes before it can output the field. At this point, the organizational information in ``vec_mask_index_list`` is critical because it describes where the data from each node should be placed in the global array. For example, the 5th processing tile may only have points 12-15 of the 6th mask, such that 

::

   vec_mask_index_list(6, 5, 1) = 12
   vec_mask_index_list(6, 5, 2) = 13
   vec_mask_index_list(6, 5, 3) = 14
   vec_mask_index_list(6, 5, 4) = 15


Once the main node has received information from all other nodes, it can output the data into a file.


Usage Notes
-----------
To use the ``diagnostics_vec`` package, the following steps must be taken:

1. Enable the package in ``packages.conf``

2. Add the compile time ``DIAGNOSTICS_VEC_SIZE.h`` file

3. Turn the ``useDiagnostics_vec`` flag in ``data.pkg`` to ``.TRUE.``

4. Generate "masks" where diagnostics will be generated

5. Generate a ``data.diagnostics_vec`` parameter file


Worked Examples
---------------
There are two verification experiments which demonstrate the use of diagnostics_vec: global_with_exf and global_ocean.cs32x15. Each of these experiments contains code_dv which constain DIAGNOSTICS_VEC_SIZE.h and packages,conf 

The generation of the sampling masks and the ``data.diagnostics_vec`` parameter file are demonstrated in these experiments.

Specifying parameters in data.diagnostics_vec
---------------------------------------------

   +------------------------+------------------------------------------------------------------------------------------+
   | Parameter              | Description                                                                              |
   +========================+==========================================================================================+
   | nml_startTime          | start time of output                                                                     |
   +------------------------+------------------------------------------------------------------------------------------+
   | nml_endTime            | end time of output                                                                       |
   +------------------------+------------------------------------------------------------------------------------------+
   | nml_vec_avg_periods    | averaging period duration of output for each vector mask                                 |
   +------------------------+------------------------------------------------------------------------------------------+
   | nml_sf_avg_periods     | averaging period duration of output for each surface mask                                |
   +------------------------+------------------------------------------------------------------------------------------+
   | nml_boundaryFiles      | filenames of lateral boundary masks                                                      |
   +------------------------+------------------------------------------------------------------------------------------+
   | nml_surfaceFiles       | filenames of surface boundary mask                                                       |
   +------------------------+------------------------------------------------------------------------------------------+
   | nml_fields2D           | field names for 2D ocean state/flux variables for each lateral boundary (e.g. ETAN)      |
   +------------------------+------------------------------------------------------------------------------------------+
   | nml_fields3D           | field names for 3D ocean state/flux variables for each lateral boundary (e.g. THETA)     |
   +------------------------+------------------------------------------------------------------------------------------+
   | nml_levels3D           | depths of 3D fields for each open boundary (starting from surface)                       |
   +------------------------+------------------------------------------------------------------------------------------+
   | nml_fieldsSurf         | field names for surface ocean state/flux variables for each surface boundary (e.g. QNET) |
   +------------------------+------------------------------------------------------------------------------------------+
   | nml_filePrec           | output file real precision (32 or 64 bits, default is 64)                                |
   +------------------------+------------------------------------------------------------------------------------------+
   | nml_combMaskTimeLevels | option to combine output fields into a single file (default is TRUE)                     |
   +------------------------+------------------------------------------------------------------------------------------+

Available diagnostics
---------------------

The following lists of variables are supported by the diagnostics_ob package.

Note: Variables listed as `Vector (2D)`, `Vector (3D)`, and `Surface (2D)` are requested via the ``nml_fields2D``, ``nml_fields3D`` and ``nml_fieldsSF`` lists in the ``data.diagnostics_vec`` file.

Standard Diagnostics
~~~~~~~~~~~~~~~~~~~~

The following diagnostics are standard model variables and are available in any configuration.
   +----------------+------------+---------------------------------------------------------------------+
   | Boundary Type  | Variable   | Description                                                         |
   +================+============+=====================================================================+
   | `Vector (2D)`  | ETAN       | surface height anomaly                                              |
   +----------------+------------+---------------------------------------------------------------------+
   |                | ETAH       | surface height anomaly                                              |
   +----------------+------------+---------------------------------------------------------------------+
   | `Vector (3D)`  | THETA      | potential temperature                                               |
   +----------------+------------+---------------------------------------------------------------------+
   |                | SALT       | salinity                                                            |
   +----------------+------------+---------------------------------------------------------------------+
   |                | UVEL       | zonal velocity                                                      |
   +----------------+------------+---------------------------------------------------------------------+
   |                | VVEL       | meridional velocity                                                 |
   +----------------+------------+---------------------------------------------------------------------+
   |                | WVEL       | vertical velocity                                                   |
   +----------------+------------+---------------------------------------------------------------------+
   |                | GU         | zonal velocity tendency                                             |
   +----------------+------------+---------------------------------------------------------------------+
   |                | GV         | meridional velocity tendency                                        |
   +----------------+------------+---------------------------------------------------------------------+
   | `Surface (2D)` | FU         | zonal wind stress                                                   |
   +----------------+------------+---------------------------------------------------------------------+
   |                | FV         | meridional wind stress                                              |
   +----------------+------------+---------------------------------------------------------------------+
   |                | QNET       | net upward surface heat flux                                        |
   +----------------+------------+---------------------------------------------------------------------+
   |                | QSW        | net upward shortwave radiation                                      |
   +----------------+------------+---------------------------------------------------------------------+
   |                | EMPMR      | net upward freshwater flux                                          |
   +----------------+------------+---------------------------------------------------------------------+
   |                | SALTFLUX   | net upward salt flux                                                |
   +----------------+------------+---------------------------------------------------------------------+
   |                | SST        | sea surface temperature                                             |
   +----------------+------------+---------------------------------------------------------------------+
   |                | SSS        | sea surface salinity                                                |
   +----------------+------------+---------------------------------------------------------------------+
   |                | LTCR       | inverse time scale for temperature relaxation                       |
   +----------------+------------+---------------------------------------------------------------------+
   |                | LSCR       | inverse time scale for salinity relaxation                          |
   +----------------+------------+---------------------------------------------------------------------+
   |                | PHITIDE2   | time-dependent geopotential anomaly                                 |
   +----------------+------------+---------------------------------------------------------------------+
   |                | PLOAD      | atmospheric pressure anomaly                                        |
   +----------------+------------+---------------------------------------------------------------------+
   |                | SICELOAD   | sea-ice loading                                                     |
   +----------------+------------+---------------------------------------------------------------------+



External Forcing Diagnostics
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following diagnostics are available in configurations with the use of `pkg/exf`.
   +----------------+------------+---------------------------------------------------------------------+
   | Boundary Type  | Variable   | Description                                                         |
   +================+============+=====================================================================+
   | `Surface (2D)` | USTRESS    | surface wind stress in the +x direction                             |
   +----------------+------------+---------------------------------------------------------------------+
   |                | VSTRESS    | surface wind stress in the +y direction                             |
   +----------------+------------+---------------------------------------------------------------------+
   |                | HFLUX      | net upward surface heat flux                                        |
   +----------------+------------+---------------------------------------------------------------------+
   |                | SFLUX      | net upward freshwater flux                                          |
   +----------------+------------+---------------------------------------------------------------------+
   |                | SWFLUX     | net upward shortwave radiation                                      |
   +----------------+------------+---------------------------------------------------------------------+
   |                | UWIND      | surface wind velocity in the +x direction                           |
   +----------------+------------+---------------------------------------------------------------------+
   |                | VWIND      | surface wind velocity in the +y direction                           |
   +----------------+------------+---------------------------------------------------------------------+
   |                | WSPEED     | surface wind speed                                                  |
   +----------------+------------+---------------------------------------------------------------------+
   |                | ATEMP      | surface air temperature                                             |
   +----------------+------------+---------------------------------------------------------------------+
   |                | AQH        | surface specific humidity                                           |
   +----------------+------------+---------------------------------------------------------------------+
   |                | HS         | sensible heat flux into the ocean                                   |
   +----------------+------------+---------------------------------------------------------------------+
   |                | HL         | latent heat flux into the ocean                                     |
   +----------------+------------+---------------------------------------------------------------------+
   |                | EVAP       | evaporation.                                                        |
   +----------------+------------+---------------------------------------------------------------------+
   |                | PRECIP     | precipitation                                                       |
   +----------------+------------+---------------------------------------------------------------------+
   |                | SNOWPREC   | snow precipitation.                                                 |
   +----------------+------------+---------------------------------------------------------------------+
   |                | RUNOFF     | runoff                                                              |
   +----------------+------------+---------------------------------------------------------------------+
   |                | SWDOWN     | downward shortwave radiation                                        |
   +----------------+------------+---------------------------------------------------------------------+
   |                | LWDOWN     | downward longwave radiation                                         |
   +----------------+------------+---------------------------------------------------------------------+
   |                | APRESS     | atmospheric pressure field.                                         |
   +----------------+------------+---------------------------------------------------------------------+


Sea Ice Diagnostics
~~~~~~~~~~~~~~~~~~~

The following diagnostics are available in configurations with the use of `pkg/seaice`.
   +----------------+------------+---------------------------------------------------------------------+
   | Boundary Type  | Variable   | Description                                                         |
   +================+============+=====================================================================+
   | `Surface (2D)` | UICE       | sea ice velocity in the +x direction                                |
   +----------------+------------+---------------------------------------------------------------------+
   |                | VICE       | sea ice velocity in the +y direction                                |
   +----------------+------------+---------------------------------------------------------------------+
   |                | AREA       | sea ice fractional ice-covered area                                 |
   +----------------+------------+---------------------------------------------------------------------+
   |                | HEFF       | sea ice effective ice thickness                                     |
   +----------------+------------+---------------------------------------------------------------------+
   |                | HSNOW      | sea ice effective snow thickness                                    |
   +----------------+------------+---------------------------------------------------------------------+


Passive Tracer Diagnostics
~~~~~~~~~~~~~~~~~~~~~~~~~~

The following diagnostics are available in configurations with the use of `pkg/ptracers`.
   +----------------+------------+---------------------------------------------------------------------+
   | Boundary Type  | Variable   | Description                                                         |
   +================+============+=====================================================================+
   | `Vector (3D)`  | PTRACEXX   | passive tracer XX where XX is between 01 and 20                     |
   +----------------+------------+---------------------------------------------------------------------+

Adding Additional Diagnostics
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The diagnostics_vec package can theoretically output any model variables as long as the variables have been 
implemented in the incrementation routine. To add output capabilities to diagnostics_vec, new variables can be
added to the `set_subfield` subroutine within :filelink:`diagnostics_vec_prepare_subfield.F <pkg/diagnostics_vec/diagnostics_vec_prepare_subfield.F>`.
When adding new variables, ensure that the associated header files are added to the subroutine header to include (define) the variables locally.
