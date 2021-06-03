# Link all files to the original verification tutorial

# Link the input files first
cd input
ln -s ../../../verification/tutorial_global_oce_biogeo/input/* ./

# Edit the data.pkg file to have the diagnostics_ob package
rm data.pkg
cp ../../../verification/tutorial_global_oce_biogeo/input/data.pkg data.pkg
sed -i '' -e '$ d' data.pkg
sed -i '' -e '$ d' data.pkg
printf " useDiagnostics_ob=.TRUE.," >> data.pkg
printf $"\n &" >> data.pkg
cd ..

# Link the files in the code directory
cd code
ln -s ../../../verification/tutorial_global_oce_biogeo/code/PTRACERS_SIZE.h PTRACERS_SIZE.h
ln -s ../../../verification/tutorial_global_oce_biogeo/code/DIAGNOSTICS_SIZE.h DIAGNOSTICS_SIZE.h
ln -s ../../../verification/tutorial_global_oce_biogeo/code/DIAG_OPTIONS.h DIAG_OPTIONS.h

# Edit the packages.conf file to have the diagnostics_ob package
cp ../../../verification/tutorial_global_oce_biogeo/code/packages.conf packages.conf
printf "diagnostics_ob" >> packages.conf

# Link the files which will eventually go in the model/src and model/inc directories
ln -s ../../new_src_inc_files/* ./
cd ..

# Create the masks
cd utils
python3 create_masks.py
cd ..
