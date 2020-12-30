.. Diagnostics_OB documentation master file

Welcome to Diagnostics_OB's documentation!
==========================================


Introduction
------------
This package is designed to output diagnostics on "slices" within the model domain.


Motivation
^^^^^^^^^^
The development of diagnostics_ob is aimed at nested-resolution modeling: an increase in spatial resolution necessitates an increase in temporal resolution to ensure convergence, yet boundary conditions are only required on a small portion of the full domain. 




Key Subroutines and Parameters
------------------------------
The storage and output of subdiagnostics is facilitated by a "lookup table" which assigns the horizontal locations of grid cells in the global domain an index within the tile in which they are processed. The lookup table is generated in the subroutine XXX.F. Subsequently, the lookup table is referenced at each model time step to update diagnostic fields and, at user-defined intervals, output averaged fields at user-specified locations. The key subroutines to generate the lookup table, and output the average subdiagnostics are listed below.

`diagnostics_ob_init_fixed.F <https://github.com/mhwood/diagnostics_ob/blob/main/diagnostics_ob/diagnostics_ob_init_fixed.F>`_





Usage Notes
-----------
To use the ``diagnostics_ob`` package, the following steps must be taken:
    1. Enable the package in ``packages.conf``
    2. Turning the ``useDiagnostics_ob`` flag in ``data.pkg`` to ``.TRUE.``
    3. Generate masks where subdiagnostics will be generated
    4. Generate a ``data.diagnostics_ob`` parameter file
    

The generation of the sampling masks and the ``data.diagnostics_ob`` parameter file are described below.


Generating Sampling Masks
^^^^^^^^^^^^^^^^^^^^^^^^^
The ``diagnostics_ob`` routines anticipates masks which sequentially enumerate sample points within a 2D domain of the same size as the full model domain (i.e. :math:`N_x \times N_y`). The mask is zero everywhere except for the points of interest.

For example, in domain of size :math:`N_x=90, N_y=40`, the following python script generates a horizontal sample mask along 
:math:`y=5` and :math:`x\in[10,30]`

::

         mask = np.zeros((40,90))
         counter = 1
         for col in range(10,31):
             mask[5][col] = counter
             counter+=1
         mask.ravel(order='C').astype('>f4').tofile('path/to/input/dir/lateral_mask.bin')


This mask would be used to sample the lateral variables, as listed below.

Similarly, the following script generates a surface sample mask within :math:`\{(x,y)|x\in[10,30], y\in[5,10]\}`

::

         mask = np.zeros((40,90))
         counter = 1
         for col in range(10,31):
             for row in range(5,10):
                 mask[row][col] = counter
                 counter+=1
         mask.ravel(order='C').astype('>f4').tofile('path/to/input/dir/surface_mask.bin')

This mask would be used to sample the surface variables, as listed below.



Specifying parameters in data.diagnostics_ob
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Within the data.diagnostics_ob file, the following parameters must be specified:
   +------------------------+------------------------------------------------------------------------------------------+
   | Parameter              | Description                                                                              |
   +========================+==========================================================================================+
   | nml_avgPeriod          | averaging period duration                                                                |
   +------------------------+------------------------------------------------------------------------------------------+
   | nml_startTime          | start time of output                                                                     |
   +------------------------+------------------------------------------------------------------------------------------+
   | nml_endTime            | end time of output                                                                       |
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


Example ``data.diagnostics_ob`` parameter file
""""""""""""""""""""""""""""""""""""""""""""""

::

         &DIAG_OB_INPUT_VARS

 	 nml_avgPeriod = 86400.,
 	 nml_startTime = 0,
 	 nml_endTime = 1576800000.,
	
 	 nml_obFiles(1) = 'boundary_mask_south.bin',
 	 nml_obFiles(2) = 'boundary_mask_east.bin',
 	 nml_obFiles(3) = 'boundary_mask_north.bin',
 	 nml_obFiles(4) = 'boundary_mask_west.bin',
	
	 nml_sfFiles(1) = 'surface_mask.bin',

	 nml_fields2D(1,1) = 'ETAN    ',
	 nml_fields2D(1,2) = 'ETAN    ',
	 nml_fields2D(1,3) = 'ETAN    ',
	 nml_fields2D(1,4) = 'ETAN    ',
	
	 nml_fields3D(1:5,1) = 'THETA   ','SALT   ','UVEL    ','VVEL    ','WVEL    ',
	 nml_levels3D(1:5,1) =   15, 15, 15, 15, 15,
	 nml_fields3D(1:5,2) = 'THETA   ','SALT   ','UVEL    ','VVEL    ','WVEL    ',
	 nml_levels3D(1:5,2) =   15, 15, 15, 15, 15,
 	 nml_fields3D(1:5,3) = 'THETA   ','SALT   ','UVEL    ','VVEL    ','WVEL    ',
 	 nml_levels3D(1:5,3) =   15, 15, 15, 15, 15,
 	 nml_fields3D(1:5,4) = 'THETA   ','SALT   ','UVEL    ','VVEL    ','WVEL    ',
	 nml_levels3D(1:5,4) =   15, 15, 15, 15, 15,

	 nml_fieldsSF(1:6,1) = 'FU      ','FV      ','SST     ','SSS     ','QNET    ','EMPMR   ',
	
	 nml_filePrec = 32,
	 nml_combMaskTimeLevels = .TRUE.,
	 &


Available diagnostics
^^^^^^^^^^^^^^^^^^^^^

The following lists of variables are supported by the diagnostics_ob package.

.. Note:: Variables listed as `Lateral (1D)`, `Lateral (2D)`, and `Surface (2D)` are requested via the ``nml_fields2D``, ``nml_fields3D`` and ``nml_fieldsSF`` lists in the ``data.diagnostics_ob`` file.

Standard Diagnostics
""""""""""""""""""""
The following diagnostics are standard model variables and are available in any configuration.
   +----------------+------------+---------------------------------------------------------------------+
   | Boundary Type  | Variable   | Description                                                         |
   +================+============+=====================================================================+
   | `Lateral (1D)` | ETAN       | surface height anomaly                                              |
   +----------------+------------+---------------------------------------------------------------------+
   |                | ETAH       | surface height anomaly                                              |
   +----------------+------------+---------------------------------------------------------------------+
   | `Lateral (2D)` | THETA      | potential temperature (deg. C)                                      |
   +----------------+------------+---------------------------------------------------------------------+
   |                | SALT       | salinity (psu)                                                      |
   +----------------+------------+---------------------------------------------------------------------+
   |                | UVEL       | zonal velocity (m/s)                                                |
   +----------------+------------+---------------------------------------------------------------------+
   |                | VVEL       | meridional velocity (m/s)                                           |
   +----------------+------------+---------------------------------------------------------------------+
   |                | WVEL       | vertical velocity (m/s)                                             |
   +----------------+------------+---------------------------------------------------------------------+
   |                | GU         |  ()                                                                 |
   +----------------+------------+---------------------------------------------------------------------+
   |                | GV         |  ()                                                                 |
   +----------------+------------+---------------------------------------------------------------------+
   | `Surface (2D)` | FU         | zonal wind stress ()                                                |
   +----------------+------------+---------------------------------------------------------------------+
   |                | FV         | meridional wind stress ()                                           |
   +----------------+------------+---------------------------------------------------------------------+
   |                | QNET       | net upward surface heat flux ()                                     |
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
""""""""""""""""""""""""""""
The following diagnostics are available in configurations with the use of `pkg/exf`.
   +----------------+------------+---------------------------------------------------------------------+
   | Boundary Type  | Variable   | Description                                                         |
   +================+============+=====================================================================+
   | `Surface (2D)` | USTRESS    | zonal surface wind stress ()                                        |
   +----------------+------------+---------------------------------------------------------------------+
   |                | VSTRESS    | meridional surface wind stress ()                                   |
   +----------------+------------+---------------------------------------------------------------------+
   |                | HFLUX      | net upward surface heat flux ()                                     |
   +----------------+------------+---------------------------------------------------------------------+
   |                | SFLUX      | net upward freshwater flux                                          |
   +----------------+------------+---------------------------------------------------------------------+
   |                | SWFLUX     | net upward fshortwave radiation                                     |
   +----------------+------------+---------------------------------------------------------------------+
   |                | UWIND      | surface zonal wind velocity                                         |
   +----------------+------------+---------------------------------------------------------------------+
   |                | VWIND      | surface meridional wind velocity                                    |
   +----------------+------------+---------------------------------------------------------------------+
   |                | WSPEED     | surface wind speed                                                  |
   +----------------+------------+---------------------------------------------------------------------+
   |                | EVAP       | evaporation                                                         |
   +----------------+------------+---------------------------------------------------------------------+
   |                | PRECIP     | total precipitation                                                 |
   +----------------+------------+---------------------------------------------------------------------+
   |                | RUNOFF     | river and glacier runoff                                            |
   +----------------+------------+---------------------------------------------------------------------+

