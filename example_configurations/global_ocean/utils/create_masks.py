
import numpy as np

#######################################################
# Define the bounds of the masks
n_rows = 40
n_cols = 90
domain_shape = (n_rows,n_cols)

# mask boundaries
min_col = 27
max_col = 63
min_row = 18
max_row = 33

#######################################################
# Make the masks

x_shift=0
y_shift=0

# Western Mask
mask = np.zeros(domain_shape)
counter = 1
for row in range(min_row,max_row+1):
    mask[row+y_shift][min_col+x_shift] = counter
    counter+=1
mask.ravel(order='C').astype('>f4').tofile('../input/lateral_mask_west.bin')

# Eastern Mask
mask = np.zeros(domain_shape)
counter = 1
for row in range(min_row,max_row+1):
    mask[row+y_shift][max_col+x_shift] = counter
    counter+=1
mask.ravel(order='C').astype('>f4').tofile('../input/lateral_mask_east.bin')

# Southern Mask
mask = np.zeros(domain_shape)
counter = 1
for col in range(min_col, max_col + 1):
    mask[min_row+y_shift][col+x_shift] = counter
    counter += 1
mask.ravel(order='C').astype('>f4').tofile('../input/lateral_mask_south.bin')

# Northern Mask
mask = np.zeros(domain_shape)
counter = 1
for col in range(min_col, max_col + 1):
    mask[max_row+y_shift][col+x_shift] = counter
    counter += 1
mask.ravel(order='C').astype('>f4').tofile('../input/lateral_mask_north.bin')

# Surface Mask
mask = np.zeros(domain_shape)
counter = 1
for row in range(min_row, max_row + 1):
    for col in range(min_col, max_col + 1):
        mask[row+y_shift][col+x_shift] = counter
        counter += 1
mask.ravel(order='C').astype('>f4').tofile('../input/surface_mask.bin')