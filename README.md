# diagnostics_vec
A diagnostics package for [MITgcm](https://github.com/MITgcm/MITgcm)

Authors: Michael Wood, Ian Fenty, April Shin

## Package Purpose and Motivation
The MITgcm model has one method for outputting model "diagnostics" for a particular experiment: dump the entire field. While entire model fields are desired for many experiements, this is not always the case. Here, we design a model package which is capable of outputting model diagnostics in a subset of the model domain e.g. along a vector (or "vec"). 

## Repository Purpose:
This repository serves as development space for the diagnostics_vec package in preparation for a pull request for implementation in the main branch of MITgcm. The main components to be included in the pull request are as follows:
- doc: updates to the documentation for the [readthedocs page](https://mitgcm.readthedocs.io/en/latest/)
- pkg: the diagnostics_vec package files
- verification: experiments to be added to the verification directory of MITgcm to ensure the package is working as desired

Note that this repository has two additional directories which will not be included in the eventual pull request:
- example_configurations: a set of examples showing how the package works in a variety of configurations - jupyter notebooks are additionally provided to demonstrate the package use
- utils: functions that facilitate the development of this package and the eventual pull request

## Testing New Files and Preparing the Fork
In order to test the new files which will be included in the pull request, there is a convenient script in the utils directory called copy_file_to_fresh_MITgcm_copy.py. This script will copy the new files from the doc, pkg, and verification into the MITgcm clone/fork. 
