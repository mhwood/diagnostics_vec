## Implementing the new documentation
The new documentation can easily be implemented into a clone (or fork) of MITgcm using the ``copy_doc_files_to_MITgcm.py`` function in the utils directory.

### A note about documentation
To view the documentation on your local machine as its viewed on [readthedocs](https://mitgcm.readthedocs.io/en/latest/), the [sphinx](https://docs.readthedocs.io/en/stable/intro/getting-started-with-sphinx.html) package is required. To download the packages used to compile the MITgcm documentation, use the following:
```
pip install sphinx
pip install sphinx-rtd-theme
pip install sphinxcontrib-bibtex<2.0     # put quotes around 'sphinxcontrib-bibtex<2.0' if using zsh
pip install sphinxcontrib-programoutput
```
Then, within the `MITgcm/docs` directory, use the following command to compile the files with sphinx:
```
make html
```
Now, you can view the files in your web browser by opening the `MITgcm/docs/_build/index.html` file.
