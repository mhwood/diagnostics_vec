
import os
import matplotlib.pyplot as plt
import numpy as np

domain_shape = (40,90)

# create the eastern mask
mask = np.zeros(domain_shape)
counter = 1
col = 45
for row in range(domain_shape[0]):
    mask[row,col] = counter
    counter+=1

file_name = os.path.join(os.getcwd(),'mask1_ctrl.bin')
mask.ravel(order='C').astype('>f4').tofile(file_name)

file_name = os.path.join(os.getcwd(),'mask1_test1.bin')
mask.ravel(order='C').astype('>f4').tofile(file_name)

file_name = os.path.join(os.getcwd(),'mask1_test2.bin')
mask.ravel(order='C').astype('>f4').tofile(file_name)

file_name = os.path.join(os.getcwd(),'mask1_test3.bin')
mask.ravel(order='C').astype('>f4').tofile(file_name)


# create the equator mask
mask = np.zeros(domain_shape)
counter = 1
row = 20
for col in range(domain_shape[1]):
    mask[row,col] = counter
    counter+=1

file_name = os.path.join(os.getcwd(),'mask2_ctrl.bin')
mask.ravel(order='C').astype('>f4').tofile(file_name)

file_name = os.path.join(os.getcwd(),'mask2_test1.bin')
mask.ravel(order='C').astype('>f4').tofile(file_name)

file_name = os.path.join(os.getcwd(),'mask2_test2.bin')
mask.ravel(order='C').astype('>f4').tofile(file_name)

file_name = os.path.join(os.getcwd(),'mask2_test3.bin')
mask.ravel(order='C').astype('>f4').tofile(file_name)

# create the surface mask
min_row = 10
max_row = 25
min_col= 10
max_col = 30
mask = np.zeros(domain_shape)
counter = 1
for row in range(min_row, max_row + 1):
    for col in range(min_col,max_col+1):
        mask[row,col] = counter
        counter+=1

file_name = os.path.join(os.getcwd(),'mask3_ctrl.bin')
mask.ravel(order='C').astype('>f4').tofile(file_name)

file_name = os.path.join(os.getcwd(),'mask3_test1.bin')
mask.ravel(order='C').astype('>f4').tofile(file_name)

file_name = os.path.join(os.getcwd(),'mask3_test2.bin')
mask.ravel(order='C').astype('>f4').tofile(file_name)

file_name = os.path.join(os.getcwd(),'mask3_test3.bin')
mask.ravel(order='C').astype('>f4').tofile(file_name)

