for VARIABLE in tutorial_global_oce_latlon tutorial_plume_on_slope tutorial_global_oce_biogeo
do
   cd $VARIABLE
   bash run.sh
   cd ..
done

# cat model_list.txt | while read line 
# do
#    cd $line
#    pwd
#    bash run.sh
#    cd ..
# done