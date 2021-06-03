
import numpy as np

#######################################################
# Define the bounds of the masks
n_cols = 320
domain_shape = (1,n_cols)

# mask boundaries
min_col = 0
max_col = 160

#######################################################
# Make the mask

mask = np.zeros(domain_shape)
counter = 1
for col in range(min_col, max_col + 1):
    mask[0][col] = counter
    counter += 1
mask.ravel(order='C').astype('>f8').tofile('../input/lateral_mask.bin')

mask = np.zeros(domain_shape)
counter = 1
for col in range(min_col, max_col + 1):
    mask[0][col] = counter
    counter += 1
mask.ravel(order='C').astype('>f8').tofile('../input/surface_mask.bin')

