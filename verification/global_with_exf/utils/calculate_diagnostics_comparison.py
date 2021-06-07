import os
import numpy as np
import matplotlib.pyplot as plt

min_row = 10
max_row = 30
min_col = 25
max_col = 65

mask_names = ['lateral_mask_south','lateral_mask_north',
              'lateral_mask_west','lateral_mask_east']
# mask_names = ['lateral_mask_south']
lateral_var_names = ['THETA']

print('Calculating differences between diagnostics_vec and standard diagnostics')

for var_name in lateral_var_names:

    print('  Differences for '+var_name+':')

    diag_vec_grids = []
    diag_grids = []

    # collect the grids from the standard model output and
    diag_file = os.path.join('..', 'run', 'T.0000000020.data')
    diag_grid = np.fromfile(diag_file,'>f4')
    diag_grid = np.reshape(diag_grid,(15,40,90))

    for mask_name in mask_names:

        # collect the grids
        var_file = os.path.join('..','run',mask_name+'_'+var_name+'.bin')
        diag_vec_grid = np.fromfile(var_file,dtype='>f4')
        if 'south' in mask_name:
            diag_vec_grid = np.reshape(diag_vec_grid, (20, 15, max_col - min_col + 1))
            diag_grid_subset = diag_grid[:,min_row, min_col:max_col+1]
        if 'north' in mask_name:
            diag_vec_grid = np.reshape(diag_vec_grid,(20,15,max_col-min_col+1))
            diag_grid_subset = diag_grid[:, max_row, min_col:max_col+1]
        if 'east' in mask_name:
            diag_vec_grid = np.reshape(diag_vec_grid,(20,15,max_row-min_row+1))
            diag_grid_subset = diag_grid[:, min_row:max_row + 1, max_col]
        if 'west' in mask_name:
            diag_vec_grid = np.reshape(diag_vec_grid,(20,15,max_row-min_row+1))
            diag_grid_subset = diag_grid[:, min_row:max_row + 1, min_col]
        diag_vec_grids.append(diag_vec_grid)
        diag_grids.append(diag_grid_subset)

    # plot the output
    for mn in range(len(mask_names)):
        diff = diag_vec_grids[mn][19,:,:] - diag_grids[mn][:, :]
        total_diff = np.sum(diff)
        if total_diff!=0:
            status='Failed'
        else:
            status='Passing'
        print('    '+mask_names[mn]+': '+'{:.2f}'.format(total_diff)+' (Status: '+status+')')





