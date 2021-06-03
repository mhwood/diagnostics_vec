for VARIABLE in tutorial_global_oce_latlon tutorial_plume_on_slope tutorial_global_oce_biogeo
do
    cd $VARIABLE
    bash setup.sh
    cd ..
done