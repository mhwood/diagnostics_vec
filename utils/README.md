# diagnostic_vec utils
The utility functions in this directory are designed to modify an MITgcm clone (or fork) with the new diagnostics_vec package. These utilities are needed for two reasons:
1. There are constant pull requests on the main branch - when the diagnostics_vec pkg is ready for a pull request, the most recent branch of MITgcm will be forked, the files in this repo will be added, and then the pull request will be submitted.
2. The PARAMS.h and package boot sequence files change between checkpoint - these functions allow for diagnostics_vec to be retroactively included in previous MITgcm checkpoints.

## Function descriptions
- copy_pkg_files_to_MITgcm.py
- copy_verification_files_to_MITgcm.py
- copy_doc_files_to_MITgcm.py

### A note about documentation
To view the documentation on your local machine as its viewed on [readthedocs](https://mitgcm.readthedocs.io/en/latest/), the [sphinx](https://docs.readthedocs.io/en/stable/intro/getting-started-with-sphinx.html) package is required. To download the packages used to compile the MITgcm documentation, use the following:
```
pip install sphinx
pip install sphinx-rtd-theme
pip install sphinxcontrib-bibtex<2.0     # put quotes around 'sphinxcontrib-bibtex<2.0' if using zsh
pip install sphinxcontrib-programoutput
```
