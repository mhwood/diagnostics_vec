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
for var_name in lateral_var_names:

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
    fig = plt.figure(figsize=(8.5,11))
    plot_counter = 1
    for mn in range(len(mask_names)):
        plt.subplot(4,3,plot_counter)
        C1 = plt.imshow(diag_vec_grids[mn][10,:,:])
        plt.ylabel(mask_names[mn].split('_')[-1])
        plot_counter += 1
        if plot_counter<3:
            plt.title('a) diagnostics_vec output')
        # if plot_counter>8:
        plt.colorbar(C1,orientation='horizontal')
        plt.gca().set_xticks([])
        plt.gca().set_yticks([])

        plt.subplot(4, 3, plot_counter)
        C2 = plt.imshow(diag_grids[mn][:, :])
        plot_counter += 1
        if plot_counter<4:
            plt.title('b) standard output')
        # if plot_counter>9:
        plt.colorbar(C2,orientation='horizontal')
        plt.gca().set_xticks([])
        plt.gca().set_yticks([])

        plt.subplot(4, 3, plot_counter)
        diff = diag_vec_grids[mn][19,:,:] - diag_grids[mn][:, :]
        C3 = plt.imshow(diff,cmap='RdBu')
        plot_counter += 1
        if plot_counter<5:
            plt.title('c) difference [a)-c)]')
        # if plot_counter>10:
        plt.colorbar(C3,orientation='horizontal')
        plt.gca().set_xticks([])
        plt.gca().set_yticks([])

    plt.suptitle('Diagnostics_vec vs Standard MITgcm Diagnostics Comparison: '+var_name)

    output_file = os.path.join('..','plots','lateral_mask_'+var_name+'_comparison.png')
    plt.savefig(output_file)
    plt.close()




