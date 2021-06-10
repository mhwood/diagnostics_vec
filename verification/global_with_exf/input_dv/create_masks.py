
import os
import matplotlib.pyplot as plt
import numpy as np

domain_shape = (40,90)
min_row = 10
max_row = 30
min_col= 25
max_col = 65

# create the eastern mask
mask = np.zeros(domain_shape)
counter = 1
for row in range(min_row,max_row+1):
    mask[row,max_col] = counter
    counter+=1
file_name = os.path.join(os.getcwd(),'lateral_mask_east.bin')
mask.ravel(order='C').astype('>f4').tofile(file_name)

# create the western mask
mask = np.zeros(domain_shape)
counter = 1
for row in range(min_row,max_row+1):
    mask[row,min_col] = counter
    counter+=1
file_name = os.path.join(os.getcwd(),'lateral_mask_west.bin')
mask.ravel(order='C').astype('>f4').tofile(file_name)

# create the southern mask
mask = np.zeros(domain_shape)
counter = 1
for col in range(min_col,max_col+1):
    mask[min_row,col] = counter
    counter+=1
file_name = os.path.join(os.getcwd(),'lateral_mask_south.bin')
mask.ravel(order='C').astype('>f4').tofile(file_name)

# create the southern mask
mask = np.zeros(domain_shape)
counter = 1
for col in range(min_col,max_col+1):
    mask[max_row,col] = counter
    counter+=1
file_name = os.path.join(os.getcwd(),'lateral_mask_north.bin')
mask.ravel(order='C').astype('>f4').tofile(file_name)

# create the surface mask
mask = np.zeros(domain_shape)
counter = 1
for row in range(min_row, max_row + 1):
    for col in range(min_col,max_col+1):
        mask[row,col] = counter
        counter+=1
file_name = os.path.join(os.getcwd(),'surface_mask.bin')
mask.ravel(order='C').astype('>f4').tofile(file_name)

