cd run
ln -s ../input/* .
mpirun -np 4 ../build/mitgcmuv
