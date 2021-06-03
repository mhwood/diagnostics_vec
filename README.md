# diagnostics_vec
A diagnostics package for [MITgcm](https://github.com/MITgcm/MITgcm)
Authors: Michael Wood, Ian Fenty, April Shin

## Repository Purpose:
This repository serves as development space for the diagnostics_vec package in preparation for a pull request for implementation in the main branch of MITgcm. The main components to be included in the pull request are as follows:
- doc: updates to the documentation for the [readthedocs page](https://mitgcm.readthedocs.io/en/latest/)
- pkg: the diagnostics_vec package files
- verification: experiments to be added to the verification directory of MITgcm to ensure the package is working as desired
Note that this repository has two additional directories which will not be included in the eventual pull request:
- example_configurations: a set of examples showing how the package works in a variety of configurations - jupyter notebooks are additionally provided to demonstrate the package use
- utils: functions that facilitate the development of this package and the eventual pull request
