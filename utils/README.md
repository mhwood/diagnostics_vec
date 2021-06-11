# diagnostic_vec utils
The utility functions in this directory are designed to modify an MITgcm clone (or fork) by adding the diagnostics_vec package and its documentation. These utilities are needed for two reasons:
1. There are constant pull requests on the main branch - when the diagnostics_vec pkg is ready for a pull request, the most recent branch of MITgcm will be forked, the files in this repo will be added, and then the pull request will be submitted.
2. The PARAMS.h and package boot sequence files change between checkpoint - these functions allow for diagnostics_vec to be retroactively included in previous MITgcm checkpoints.

## Function descriptions
- copy_pkg_files_to_MITgcm.py
- copy_verification_files_to_MITgcm.py
- copy_doc_files_to_MITgcm.py

