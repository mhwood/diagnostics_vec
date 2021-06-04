## Verification Experiements
For package verification (and demonstration), we modify two commonly-used tutorial MITgcm tutorial experiements.

## global_with_exf
The [global_with_exf](https://github.com/MITgcm/MITgcm/tree/master/verification/global_with_exf) experiment is itself a modification of the tutorial_global_oce_latlon experiement, with the exception that it applies external forcing fields. Here, we provide an alternative but nearly identical experiement which uses the diagnostics_vec package to output various diagnostics including prognostic variables as well as fields from the exf package. To examine how the diagnostics_vec package is configured for this experiment, see the jupyter notebook file provided (or the README file for a brief synopsis).

## global_ocean.cs32x15
The [global_ocean.cs32x15](https://github.com/MITgcm/MITgcm/tree/master/verification/global_ocean.cs32x15) experiment provides a demonstration of a cubed sphere configuration that utilizes the exch2 package. Numerically, the model grid is stored in a long array, with tile connections described by the data.exch2 file (or defined implicitly in the code). Here, we demonstrate that the diagnostics_vec package can handle configuration that utilize the exch2 configurations.
