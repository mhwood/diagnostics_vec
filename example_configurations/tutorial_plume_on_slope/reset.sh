# This script returns the directory to its distributable form
cd input
shopt -s extglob
rm -v !("data.diagnostics_ob")
cd ..
rm build/*
rm run/*
cd code
shopt -s extglob
rm -v !("DIAGNOSTICS_OB.h")
cd ..
