
import numpy as np

#######################################################
# Define the bounds of the masks
n_rows = 64
n_cols = 128
domain_shape = (n_rows,n_cols)

# mask boundaries
min_col = 50
max_col = 55
min_row = 40
max_row = 45

#######################################################
# Make the masks

# Western Mask
mask = np.zeros(domain_shape)
counter = 1
for row in range(min_row,max_row+1):
    mask[row][min_col] = counter
    counter+=1
mask.ravel(order='C').astype('>f4').tofile('../input/lateral_mask_west.bin')

# Eastern Mask
mask = np.zeros(domain_shape)
counter = 1
for row in range(min_row,max_row+1):
    mask[row][max_col] = counter
    counter+=1
mask.ravel(order='C').astype('>f4').tofile('../input/lateral_mask_east.bin')

# Southern Mask
mask = np.zeros(domain_shape)
counter = 1
for col in range(min_col, max_col + 1):
    mask[min_row][col] = counter
    counter += 1
mask.ravel(order='C').astype('>f4').tofile('../input/lateral_mask_south.bin')

# Northern Mask
mask = np.zeros(domain_shape)
counter = 1
for col in range(min_col, max_col + 1):
    mask[max_row][col] = counter
    counter += 1
mask.ravel(order='C').astype('>f4').tofile('../input/lateral_mask_north.bin')

# Surface Mask
mask = np.zeros(domain_shape)
counter = 1
for row in range(min_row, max_row + 1):
    for col in range(min_col, max_col + 1):
        mask[row][col] = counter
        counter += 1
mask.ravel(order='C').astype('>f4').tofile('../input/surface_mask.bin')

