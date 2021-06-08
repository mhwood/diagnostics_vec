Utilities
*********

.. _MITgcmutils:

MITgcmutils
===========

This Python package includes a number of helpful functions and scripts for dealing with MITgcm output.
You can install it from the model repository (in directory :filelink:`utils/python/MITgcmutils`)
or from the Python Package Index:

::

    pip install --user MITgcmutils

The following functions are exposed at the package level:

- from module mds: :meth:`~MITgcmutils.mds.rdmds` and :meth:`~MITgcmutils.mds.wrmds`
- from module mnc: :meth:`~MITgcmutils.mnc.rdmnc` and :meth:`~MITgcmutils.mnc.mnc_files`
- from module ptracers: :meth:`~MITgcmutils.ptracers.iolabel` and: :meth:`~MITgcmutils.ptracers.iolabel2num`
- from module diagnostics: :meth:`~MITgcmutils.diagnostics.readstats`

The package also includes a standalone script for joining tiled mnc files: gluemncbig_.

For more functions, see the individual modules:

mds
---

.. automodule:: MITgcmutils.mds
    :members:

mnc
---

.. automodule:: MITgcmutils.mnc
    :members:

diagnostics
-----------

.. automodule:: MITgcmutils.diagnostics
    :members:

ptracers
--------

.. automodule:: MITgcmutils.ptracers
    :members:

jmd95
-----

.. automodule:: MITgcmutils.jmd95
    :members:

mdjwf
-----

.. automodule:: MITgcmutils.mdjwf
    :members:

cs
--

.. automodule:: MITgcmutils.cs
    :members:

llc
---

.. automodule:: MITgcmutils.llc
    :members:

.. _gluemncbig:

gluemncbig
----------

This command line script is part of MITgcmutils and provides a convenient method
for stitching together NetCDF files into a single file covering the model domain.
Be careful though - the resulting files can get very large.

.. program-output:: ../utils/python/MITgcmutils/scripts/gluemncbig --help


Grid Generation
===============

The horizontal discretizations within MITgcm have been written to work
with many different grid types including:

-  cartesian coordinates

-  spherical polar (“latitude-longitude”) coordinates

-  general curvilinear orthogonal coordinates

The last of these, especially when combined with the domain
decomposition capabilities of MITgcm, allows a great degree of grid
flexibility. To date, general curvilinear orthogonal coordinates have
been used extensively in conjunction with
so-called “cubed sphere” grids. However, it is important to observe that
cubed sphere arrangements are only one example of what is possible with
domain-decomposed logically rectangular regions each containing
curvilinear orthogonal coordinate systems. Much more sophisticated
domains can be imagined and constructed.

In order to explore the possibilities of domain-decomposed curvilinear
orthogonal coordinate systems, a suite of grid generation software
called “SPGrid” (for SPherical Gridding) has been developed. SPGrid is a
relatively new facility and papers detailing its algorithms are in
preparation. Although SPGrid is new and rapidly developing, it has
already demonstrated the ability to generate some useful and interesting
grids.

This section provides a very brief introduction to SPGrid and shows some
early results. For further information, please contact the MITgcm
support list MITgcm-support@mitgcm.org.

Using SPGrid
------------

The SPGrid software is not a single program. Rather, it is a collection
of C++ code and `MATLAB <https://www.mathworks.com/>`_ scripts that can be used as a framework or
library for grid generation and manipulation. Currently, grid creation
is accomplished by either directly running `MATLAB <https://www.mathworks.com/>`_ scripts or by writing
a C++ “driver” program. The `MATLAB <https://www.mathworks.com/>`_ scripts are suitable for grids
composed of a single “face” (that is, a single logically rectangular
region on the surface of a sphere). The C++ driver programs are
appropriate for grids composed of multiple connected logically
rectangular patches. Each driver program is written to specify the
shape and connectivity of tiles and the preferred grid density (that is,
the number of grid cells in each logical direction) and edge locations
of the cells where they meet the edges of each face. The driver programs
pass this information to the SPGrid library, which generates the actual
grid and produces the output files that describe it.

Currently, driver programs are available for a few examples including
cubes, “lat-lon caps” (cube topologies that have conformal caps at the
poles and are exactly lat-lon channels for the remainder of the domain),
and some simple “embedded” regions that are meant to be used within
typical cubes or traditional lat-lon grids.

To create new grids, one may start with an existing driver program and
modify it to describe a domain that has a different arrangement. The
number, location, size, and connectivity of grid “faces” (the name used
for the logically rectangular regions) can be readily changed. Further,
the number of grid cells within faces and the location of the grid cells
at the face edges can also be specified.

SPGrid requirements
~~~~~~~~~~~~~~~~~~~

The following programs and libraries are required to build and/or run
the SPGrid suite:

-  `MATLAB <https://www.mathworks.com/>`_ is a run-time requirement since many of the generation
   algorithms have been written as `MATLAB <https://www.mathworks.com/>`_ scripts.

-  The `Geometric Tools Engine <https://geometrictools.com>`_  (a C++ library) is needed for the
   main “driver” code.

-  The `netCDF <http://www.unidata.ucar.edu/software/netcdf/>`_ library is needed for file I/O.

-  The `Boost serialization library <http://www.boost.org/doc/libs/1_66_0/libs/serialization/doc/index.html>`_ is also used for I/O:

-  a typical Linux/Unix build environment including the make utility
   (preferably GNU Make) and a C++ compiler (SPGrid was developed with
   g++ v4.x).

Obtaining SPGrid
~~~~~~~~~~~~~~~~

The latest version can be obtained from:


Building SPGrid
~~~~~~~~~~~~~~~

The procedure for building is similar to many open source projects:

::

         tar -xf spgrid-0.9.4.tar.gz
         cd spgrid-0.9.4
         export CPPFLAGS="-I/usr/include/netcdf-3"
         export LDFLAGS="-L/usr/lib/netcdf-3"
         ./configure
         make

where the ``CPPFLAGS`` and ``LDFLAGS`` environment variables can be
edited to reflect the locations of all the necessary dependencies.
SPGrid is known to work on Fedora Core Linux (versions 4 and 5) and is
likely to work on most any Linux distribution that provides the needed
dependencies.

Running SPGrid
~~~~~~~~~~~~~~

Within the ``src`` sub-directory, various example driver programs exist.
These examples describe small, simple domains and can generate the input
files (formatted as either binary ``*.mitgrid`` or netCDF) used by
MITgcm.

One such example is called ``SpF_test_cube_cap`` and it can be run with
the following sequence of commands:

::

         cd spgrid-0.9.4/src
         make SpF_test_cube_cap
         mkdir SpF_test_cube_cap.d
         ( cd SpF_test_cube_cap.d && ln -s ../../scripts/*.m . )
         ./SpF_test_cube_cap

which should create a series of output files:

::

         SpF_test_cube_cap.d/grid_*.mitgrid
         SpF_test_cube_cap.d/grid_*.nc
         SpF_test_cube_cap.d/std_topology.nc

where the ``grid_.mitgrid`` and ``grid_.nc`` files contain the grid
information in binary and netCDF formats and the ``std_topology.nc``
file contains the information describing the connectivity (both
edge–edge and corner–corner contacts) between all the faces.

Example Grids
-------------

The following grids are various examples created with SPGrid.

Pre– and Post–Processing Scripts and Utilities
==============================================

There are numerous tools for pre-processing data, converting model
output and analysis written in `MATLAB <https://www.mathworks.com/>`_, Fortran (f77 and f90) and perl.
As yet they remain undocumented although many are self-documenting
(`MATLAB <https://www.mathworks.com/>`_ routines have “help” written into them).

Here we’ll summarize what is available but this is an ever growing
resource so this may not cover everything that is out there:

Utilities Supplied With the Model
---------------------------------

We supply some basic scripts with the model to facilitate conversion or
reading of data into analysis software.

utils/scripts
~~~~~~~~~~~~~

In the directory :filelink:`utils/scripts`,  :filelink:`joinds <utils/scripts/joinds>`
and :filelink:`joinmds <utils/scripts/joinmds>`
are perl scripts used to joining multi-part files created by
MITgcm. Use :filelink:`joinmds <utils/scripts/joinmds>`.
You will only need :filelink:`joinds <utils/scripts/joinds>` if you are
working with output older than two years (prior to c23).

utils/matlab
~~~~~~~~~~~~

In the directory :filelink:`utils/matlab` you will find
several `MATLAB <https://www.mathworks.com/>`_  scripts (``.m``
files). The principle script is :filelink:`rdmds.m <utils/matlab/rdmds.m>`, used for reading
the multi-part model output files into `MATLAB <https://www.mathworks.com/>`_ . Place the scripts in
your `MATLAB <https://www.mathworks.com/>`_  path or change the path appropriately,
then at the `MATLAB <https://www.mathworks.com/>`_
prompt type:

::

      >> help rdmds

to get help on how to use :filelink:`rdmds <utils/matlab/rdmds.m>`.

Another useful script scans the terminal output file for :filelink:`pkg/monitor`
information.

Most other scripts are for working in the curvilinear coordinate systems,
and as yet are unpublished and undocumented.

pkg/mnc utils
~~~~~~~~~~~~~

The following scripts and
utilities have been written to help manipulate `netCDF <http://www.unidata.ucar.edu/software/netcdf/>`_ files:

Tile Assembly:
    A `MATLAB <https://www.mathworks.com/>`_ script
    :filelink:`mnc_assembly.m <utils/matlab/mnc_assembly.m>` is available for
    spatially “assembling” :filelink:`pkg/mnc` output. A convenience wrapper script
    called :filelink:`gluemnc.m <utils/matlab/gluemnc.m>` is also provided. Please use the
    `MATLAB <https://www.mathworks.com/>`_ help facility for more information.

gmt:
    As MITgcm evolves to handle more complicated domains and topologies,
    a suite of matlab tools is being written to more gracefully handle
    the model files. This suite is called “gmt” which refers to
    “generalized model topology” pre-/post-processing. Currently, this
    directory contains a `MATLAB <https://www.mathworks.com/>`_ script
    :filelink:`gmt/rdnctiles.m <utils/matlab/gmt/rdnctiles.m>` that
    is able to read `netCDF <http://www.unidata.ucar.edu/software/netcdf/>`_ files for any domain.
    Additional scripts are being created that will work with these
    fields on a per-tile basis.

Pre-Processing Software
-----------------------

There is a suite of pre-processing software for interpolating bathymetry
and forcing data, written by Adcroft and Biastoch. At some point, these
will be made available for download. If you are in need of such
software, contact one of them.

Potential Vorticity Matlab Toolbox
==================================

Author: Guillaume Maze

Introduction
------------

This section of the documentation describes a `MATLAB <https://www.mathworks.com/>`_  package that aims
to provide useful routines to compute vorticity fields (relative,
potential and planetary) and its related components. This is an offline
computation. It was developed to be used in mode water studies, so that
it comes with other related routines, in particular ones computing
surface vertical potential vorticity fluxes.

Equations
---------

Potential vorticity
~~~~~~~~~~~~~~~~~~~

The package computes the three components of the relative vorticity
defined by:

.. math::
   \begin{aligned}
     \omega &= \nabla \times {\bf U} = \left( \begin{array}{c}
         \omega_x\\
         \omega_y\\
         \zeta
     \end{array}\right)
        \simeq &\left( \begin{array}{c}
         -\frac{\partial v}{\partial z}\\
         -\frac{\partial u}{\partial z}\\
         \frac{\partial v}{\partial x} - \frac{\partial u}{\partial y}
     \end{array}\right)\end{aligned}
   :label: pv_eq1

where we omitted the vertical velocity component (as done throughout the package).

The package then computes the potential vorticity as:

.. math::
   \begin{aligned}
   Q &= -\frac{1}{\rho} \omega\cdot\nabla\sigma_\theta\\
    &= -\frac{1}{\rho}\left(\omega_x \frac{\partial \sigma_\theta}{\partial x} +
   \omega_y \frac{\partial \sigma_\theta}{\partial y} +
   \left(f+\zeta\right) \frac{\partial \sigma_\theta}{\partial z}\right)\end{aligned}
   :label: pv_eq2

where :math:`\rho` is the density, :math:`\sigma_\theta` is the
potential density (both eventually computed by the package) and
:math:`f` is the Coriolis parameter.

The package is also able to compute the simpler planetary vorticity as:

.. math::
   \begin{aligned}
   Q_{spl} &=& -\frac{f}{\rho}\frac{\sigma_\theta}{\partial z}\end{aligned}
   :label: pv_eq3

Surface vertical potential vorticity fluxes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These quantities are useful in mode water studies because of the
impermeability theorem which states that for a given potential density
layer (embedding a mode water), the integrated PV only changes through
surface input/output.

Vertical PV fluxes due to frictional and diabatic processes are given
by:

.. math::
   J^B_z = -\frac{f}{h}\left( \frac{\alpha Q_{net}}{C_w}-\rho_0 \beta S_{net}\right)
   :label: pv_eq14a

.. math::
   J^F_z = \frac{1}{\rho\delta_e} \vec{k}\times\tau\cdot\nabla\sigma_m
  :label: pv_eq15a

These components can be computed with the package. Details on the
variables definition and the way these fluxes are derived can be found
in :numref:`notes_flux_form`.

We now give some simple explanations about these fluxes and how they can
reduce the PV value of an oceanic potential density layer.

Diabatic process
^^^^^^^^^^^^^^^^

Let’s take the PV flux due to surface buoyancy forcing from
:eq:`pv_eq14a` and simplify it as:

.. math::

   \begin{aligned}
     J^B_z &\simeq& -\frac{\alpha f}{hC_w} Q_{net}\end{aligned}

When the net surface heat flux :math:`Q_{net}` is upward, i.e., negative
and cooling the ocean (buoyancy loss), surface density will increase,
triggering mixing which reduces the stratification and then the PV.

.. math::
   \begin{aligned}
     Q_{net} &< 0 \phantom{WWW}\text{(upward, cooling)} \\
     J^B_z   &> 0 \phantom{WWW}\text{(upward)} \\
     -\rho^{-1}\nabla\cdot J^B_z &< 0 \phantom{WWW}\text{(PV flux divergence)} \\
     PV &\searrow \phantom{WWWi}\text{where } Q_{net}<0 \end{aligned}


Frictional process: “Down-front” wind-stress
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Now let’s take the PV flux due to the “wind-driven buoyancy flux” from
:eq:`pv_eq15a` and simplify it as:

.. math::
   \begin{aligned}
     J^F_z &= \frac{1}{\rho\delta_e} \left( \tau_x\frac{\partial \sigma}{\partial y} - \tau_y\frac{\partial \sigma}{\partial x} \right) \\
     &\simeq \frac{1}{\rho\delta_e} \tau_x\frac{\partial \sigma}{\partial y} \end{aligned}

When the wind is blowing from the east above the Gulf Stream (a region
of high meridional density gradient), it induces an advection of dense
water from the northern side of the GS to the southern side through
Ekman currents. Then, it induces a “wind-driven” buoyancy lost and
mixing which reduces the stratification and the PV.

.. math::
   \begin{aligned}
    \vec{k}\times\tau\cdot\nabla\sigma &> 0 \phantom{WWW}\text{("Down-front" wind)} \\
    J^F_z &> 0 \phantom{WWW}\text{(upward)} \\
     -\rho^{-1}\nabla\cdot J^F_z &< 0 \phantom{WWW}\text{(PV flux divergence)} \\
     PV &\searrow \phantom{WWW}\text{where } \vec{k}\times\tau\cdot\nabla\sigma>0 \end{aligned}


Diabatic versus frictional processes
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A recent debate in the community arose about the relative role of these
processes. Taking the ratio of :eq:`pv_eq14a` and
:eq:`pv_eq15a` leads to:

.. math::

   \begin{aligned}
     \frac{J^F_z}{J^B_Z} &=& \frac{ \frac{1}{\rho\delta_e} \vec{k}\times\tau\cdot\nabla\sigma }
     {-\frac{f}{h}\left( \frac{\alpha Q_{net}}{C_w}-\rho_0 \beta S_{net}\right)} \\
     &\simeq& \frac{Q_{Ek}/\delta_e}{Q_{net}/h} \nonumber\end{aligned}

where appears the lateral heat flux induced by Ekman currents:

.. math::

   \begin{aligned}
     Q_{Ek} &=& -\frac{C_w}{\alpha\rho f}\vec{k}\times\tau\cdot\nabla\sigma
     \nonumber \\
     &=& \frac{C_w}{\alpha}\delta_e\vec{u_{Ek}}\cdot\nabla\sigma\end{aligned}

which can be computed with the package. In the aim of comparing both
processes, it will be useful to plot surface net and lateral
Ekman-induced heat fluxes together with PV fluxes.

Key routines
------------

-  **A_compute_potential_density.m**: Compute the potential density
   field. Requires the potential temperature and salinity (either total
   or anomalous) and produces one output file with the potential density
   field (file prefix is ``SIGMATHETA``). The routine uses :filelink:`utils/matlab/densjmd95.m`,
   a Matlab counterpart of the MITgcm built-in function to compute the
   density.

-  **B_compute_relative_vorticity.m**: Compute the three components
   of the relative vorticity defined in :eq:`pv_eq1`.
   Requires the two horizontal velocity components and produces three
   output files with the three components (files prefix are ``OMEGAX``,
   ``OMEGAY`` and ``ZETA``).

-  **C_compute_potential_vorticity.m**: Compute the potential
   vorticity without the negative ratio by the density. Two options are
   possible in order to compute either the full component (term into
   parenthesis in :eq:`pv_eq2` or the planetary component
   (:math:`f\partial_z\sigma_\theta` in :eq:`pv_eq3`). Requires
   the relative vorticity components and the potential density, and
   produces one output file with the potential vorticity (file prefix is
   ``PV`` for the full term and ``splPV`` for the planetary component).

-  **D_compute_potential_vorticity.m**: Load the field computed with
   and divide it by :math:`-\rho` to obtain the correct potential
   vorticity. Require the density field and after loading, overwrite the
   file with prefix ``PV`` or ``splPV``.

-  **compute_density.m**: Compute the density :math:`\rho` from the
   potential temperature and the salinity fields.

-  **compute_JFz.m**: Compute the surface vertical PV flux due to
   frictional processes. Requires the wind stress components, density,
   potential density and Ekman layer depth (all of them, except the wind
   stress, may be computed with the package), and produces one output
   file with the PV flux :math:`J^F_z` (see :eq:`pv_eq15a` and
   with ``JFz`` as a prefix.

-  **compute_JBz.m**: Compute the surface vertical PV flux due to
   diabatic processes as:

   .. math::
      \begin{aligned}
        J^B_z &=& -\frac{f}{h}\frac{\alpha Q_{net}}{C_w} \end{aligned}

   which is a simplified version of the full expression given in
   :eq:`pv_eq14a`. Requires the net surface heat flux and the
   mixed layer depth (of which an estimation can be computed with the
   package), and produces one output file with the PV flux :math:`J^B_z`
   and with JBz as a prefix.

-  **compute\_QEk.m**: Compute the horizontal heat flux due to Ekman
   currents from the PV flux induced by frictional forces as:

   .. math::
      \begin{aligned}
       Q_{Ek} &=& - \frac{C_w \delta_e}{\alpha f}J^F_z\end{aligned}

   Requires the PV flux due to frictional forces and the Ekman layer
   depth, and produces one output with the heat flux and with QEk as a
   prefix.

-  **eg\_main\_getPV**: A complete example of how to set up a master
   routine able to compute everything from the package.

Technical details
-----------------

File name
~~~~~~~~~

A file name is formed by three parameters which need to be set up as
global variables in `MATLAB <https://www.mathworks.com/>`_ before running any routines. They are:

-  the prefix, i.e., the variable name (``netcdf_UVEL`` for example). This
   parameter is specified in the help section of all diagnostic
   routines.

-  ``netcdf_domain``: the geographical domain.

-  ``netcdf_suff``: the netcdf extension (nc or cdf for example).

Then, for example, if the calling `MATLAB <https://www.mathworks.com/>`_ routine had set up:

::

    global netcdf_THETA netcdf_SALTanom netcdf_domain netcdf_suff
    netcdf_THETA    = 'THETA';
    netcdf_SALTanom = 'SALT';
    netcdf_domain   = 'north_atlantic';
    netcdf_suff     = 'nc';

the routine A_compute_potential_density.m to compute the potential
density field, will look for the files:

::

    THETA.north_atlantic.nc
    SALT.north_atlantic.nc

and the output file will automatically be:
``SIGMATHETA.north_atlantic.nc``.

Otherwise indicated, output file prefix cannot be changed.

Path to file
~~~~~~~~~~~~

All diagnostic routines look for input files in a subdirectory (relative
to the `MATLAB <https://www.mathworks.com/>`_ routine directory)
called ``./netcdf-files``, which in turn is
supposed to contain subdirectories for each set of fields. For example,
computing the potential density for the timestep 12H00 02/03/2005 will
require a subdirectory with the potential temperature and salinity files
like:

::

    ./netcdf-files/200501031200/THETA.north_atlantic.nc
    ./netcdf-files/200501031200/SALT.north_atlantic.nc

The output file ``SIGMATHETA.north\_atlantic.nc`` will be created in
``./netcdf-files/200501031200/``. All diagnostic routines take as argument
the name of the timestep subdirectory into ``./netcdf-files``.

Grids
~~~~~

With MITgcm numerical outputs, velocity and tracer fields may not be
defined on the same grid. Usually, ``UVEL`` and ``VVEL`` are defined on a C-grid
but when interpolated from a cube-sphere simulation they are defined on
a A-grid. When it is needed, routines allow to set up a global variable
which define the grid to use.

.. _notes_flux_form:

Notes on the flux form of the PV equation and vertical PV fluxes
----------------------------------------------------------------

Flux form of the PV equation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The conservative flux form of the potential vorticity equation is:

.. math::
   \begin{aligned}
   \frac{\partial \rho Q}{\partial t} + \nabla \cdot \vec{J} &=& 0 \end{aligned}
   :label: pv_eq4

where the potential vorticity :math:`Q` is given by :eq:`pv_eq2`.

The generalized flux vector of potential vorticity is:

.. math::
   \begin{aligned}
    \vec{J} &=& \rho Q \vec{u} + \vec{N_Q}\end{aligned}

which allows to rewrite :eq:`pv_eq4` as:

.. math::
   \begin{aligned}
   \frac{DQ}{dt} &=& -\frac{1}{\rho}\nabla\cdot\vec{N_Q}\end{aligned}
   :label: pv_eq5

where the non-advective PV flux :math:`\vec{N_Q}` is given by:

.. math::
   \begin{aligned}
   \vec{N_Q} &=& -\frac{\rho_0}{g}B\vec{\omega_a} + \vec{F}\times\nabla\sigma_\theta \end{aligned}
   :label: pv_eq6

Its first component is linked to the buoyancy forcing:

.. math::
   \begin{aligned}
    B &=& -\frac{g}{\rho_o}\frac{D \sigma_\theta}{dt} \end{aligned}

and the second one to the non-conservative body forces per unit mass:

.. math::
   \begin{aligned}
    \vec{F} &=& \frac{D \vec{u}}{dt} + 2\Omega\times\vec{u} + \nabla p \end{aligned}

Note that introducing :math:`B` into :eq:`pv_eq6` yields:

   .. math::
      \begin{aligned}
        \vec{N_Q} &=& \omega_a \frac{D \sigma_\theta}{dt} + \vec{F}\times\nabla\sigma_\theta\end{aligned}


Determining the PV flux at the ocean’s surface
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In the context of mode water study, we are particularly interested in how
the PV may be reduced by surface PV fluxes because a mode water is
characterized by a low PV value. Considering the volume limited by two
:math:`iso-\sigma_\theta`, PV flux is limited to surface processes and
then vertical component of :math:`\vec{N_Q}`. It is supposed that
:math:`B` and :math:`\vec{F}` will only be non-zero in the mixed layer
(of depth :math:`h` and variable density :math:`\sigma_m`) exposed to
mechanical forcing by the wind and buoyancy fluxes through the ocean’s
surface.

Given the assumption of a mechanical forcing confined to a thin surface
Ekman layer (of depth :math:`\delta_e`, eventually computed by the
package) and of hydrostatic and geostrophic balances, we can write:

.. math::
   \begin{aligned}
     \vec{u_g} &=& \frac{1}{\rho f} \vec{k}\times\nabla p \\
     \frac{\partial p_m}{\partial z} &=& -\sigma_m g \\
     \frac{\partial \sigma_m}{\partial t} + \vec{u}_m\cdot\nabla\sigma_m &=& -\frac{\rho_0}{g}B \end{aligned}
   :label: pv_eq7

where:

.. math::
   \begin{aligned}
     \vec{u}_m &=& \vec{u}_g + \vec{u}_{Ek} + o(R_o) \end{aligned}
   :label: pv_eq8

is the full velocity field composed of the geostrophic current
:math:`\vec{u}_g` and the Ekman drift:

.. math::
  \begin{aligned}
     \vec{u}_{Ek} &=& -\frac{1}{\rho f}\vec{k}\times\frac{\partial \tau}{\partial z}\end{aligned}
  :label: pv_eq9

(where :math:`\tau` is the wind stress) and last by other ageostrophic
components of :math:`o(R_o)` which are neglected.

Partitioning the buoyancy forcing as:

.. math::
   \begin{aligned}
     B &=& B_g + B_{Ek}\end{aligned}
   :label: pv_eq10

and using :eq:`pv_eq8` and :eq:`pv_eq9`, :eq:`pv_eq7` becomes:

.. math::
   \begin{aligned}
    \frac{\partial \sigma_m}{\partial t} + \vec{u}_g\cdot\nabla\sigma_m &=& -\frac{\rho_0}{g} B_g\end{aligned}

revealing the “wind-driven buoyancy forcing”:

.. math::
   \begin{aligned}
     B_{Ek} &=& \frac{g}{\rho_0}\frac{1}{\rho f}\left(\vec{k}\times\frac{\partial \tau}{\partial z}\right)\cdot\nabla\sigma_m\end{aligned}

Note that since:

.. math::
   \begin{aligned}
     \frac{\partial B_g}{\partial z} &=& \frac{\partial}{\partial z}\left(-\frac{g}{\rho_0}\vec{u_g}\cdot\nabla\sigma_m\right)
     = -\frac{g}{\rho_0}\frac{\partial \vec{u_g}}{\partial z}\cdot\nabla\sigma_m
     = 0\end{aligned}

:math:`B_g` must be uniform throughout the depth of the mixed layer and
then being related to the surface buoyancy flux by integrating
:eq:`pv_eq10` through the mixed layer:

.. math::
   \begin{aligned}
     \int_{-h}^0B\,dz &=\, hB_g + \int_{-h}^0B_{Ek}\,dz  \,=& \mathcal{B}_{in}\end{aligned}
   :label: pv_eq11

where :math:`\mathcal{B}_{in}` is the vertically integrated surface buoyancy (in)flux:

.. math::
   \begin{aligned}
     \mathcal{B}_{in} &=& \frac{g}{\rho_o}\left( \frac{\alpha Q_{net}}{C_w} - \rho_0\beta S_{net}\right)\end{aligned}
   :label: pv_eq12

with :math:`\alpha\simeq 2.5\times10^{-4}\, \text{K}^{-1}` the thermal
expansion coefficient (computed by the package otherwise),
:math:`C_w=4187 \text{ J kg}^{-1}\text{K}^{-1}` the specific heat of
seawater, :math:`Q_{net}\text{ (W m$^{-2}$)}` the net heat surface
flux (positive downward, warming the ocean), :math:`\beta\text{
((g/kg)$^{-1}$)}` the saline contraction coefficient, and
:math:`S_{net}=S*(E-P)\text{ ((g/kg) m s$^{-1}$)}` the net freshwater
surface flux with :math:`S\text{ (g/kg)}` the surface salinity and
:math:`(E-P)\text{ (m s$^{-1}$)}` the fresh water flux.

Introducing the body force in the Ekman layer:

.. math::
   \begin{aligned}
     F_z &=& \frac{1}{\rho}\frac{\partial \tau}{\partial z}\end{aligned}

the vertical component of :eq:`pv_eq6` is:

.. math::
   \begin{aligned}
     \vec{N_Q}_z &= -\frac{\rho_0}{g}(B_g+B_{Ek})\omega_z
     + \frac{1}{\rho}
     \left( \frac{\partial \tau}{\partial z}\times\nabla\sigma_\theta \right)\cdot\vec{k} \\
     &= -\frac{\rho_0}{g}B_g\omega_z
     -\frac{\rho_0}{g}
     \left(\frac{g}{\rho_0}\frac{1}{\rho f}\vec{k}\times\frac{\partial \tau}{\partial z}
       \cdot\nabla\sigma_m\right)\omega_z
     + \frac{1}{\rho}
     \left( \frac{\partial \tau}{\partial z}\times\nabla\sigma_\theta \right)\cdot\vec{k}\\
     &= -\frac{\rho_0}{g}B_g\omega_z
     + \left(1-\frac{\omega_z}{f}\right)\left(\frac{1}{\rho}\frac{\partial \tau}{\partial z}
                   \times\nabla\sigma_\theta \right)\cdot\vec{k}\end{aligned}

and given the assumption that :math:`\omega_z\simeq f`, the second term
vanishes and we obtain:

.. math::
   \begin{aligned}
     \vec{N_Q}_z &=& -\frac{\rho_0}{g}f B_g\end{aligned}
   :label: pv_eq13

Note that the wind-stress forcing does not appear explicitly here but
is implicit in :math:`B_g` through :eq:`pv_eq11`: the buoyancy
forcing :math:`B_g` is determined by the difference between the
integrated surface buoyancy flux :math:`\mathcal{B}_{in}` and the
integrated “wind-driven buoyancy forcing”:

.. math::

   \begin{aligned}
     B_g &= \frac{1}{h}\left( \mathcal{B}_{in} - \int_{-h}^0B_{Ek}dz \right)  \\
     &= \frac{1}{h}\frac{g}{\rho_0}\left( \frac{\alpha Q_{net}}{C_w} - \rho_0 \beta S_{net}\right)
     - \frac{1}{h}\int_{-h}^0
     \frac{g}{\rho_0}\frac{1}{\rho f}\vec{k}\times \frac{\partial \tau}{\partial z} \cdot\nabla\sigma_m dz \\
     &= \frac{1}{h}\frac{g}{\rho_0}\left( \frac{\alpha Q_{net}}{C_w} - \rho_0 \beta S_{net}\right)
     - \frac{g}{\rho_0}\frac{1}{\rho f \delta_e}\vec{k}\times\tau\cdot\nabla\sigma_m\end{aligned}

Finally, from :eq:`pv_eq6`, the vertical surface flux of PV may
be written as:

.. math::
   \begin{aligned}
     \vec{N_Q}_z &= J^B_z + J^F_z  \\
     J^B_z &= -\frac{f}{h}\left( \frac{\alpha Q_{net}}{C_w}-\rho_0 \beta S_{net}\right) \\
     J^F_z &= \frac{1}{\rho\delta_e} \vec{k}\times\tau\cdot\nabla\sigma_m \end{aligned}

