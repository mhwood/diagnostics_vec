import os
import matplotlib.pyplot as plt
import numpy as np

def read_cs32_faces(input_dir):
    XCs = []
    YCs = []

    for i in range(1, 7):
        test_file = os.path.join(input_dir, 'grid_cs32.face' + '{:03d}'.format(i) + '.bin')

        grid = np.fromfile(test_file, dtype='>f8')
        grid = np.reshape(grid, (18, 33, 33))

        XC = grid[0][:-1, :-1]
        YC = grid[1][:-1, :-1]
        XCs.append(XC)
        YCs.append(YC)

        XC = np.reshape(XC, (32, 1, 32))
        YC = np.reshape(YC, (32, 1, 32))
        if i == 1:
            X = XC
            Y = YC
        else:
            X = np.concatenate([X, XC], axis=1)
            Y = np.concatenate([Y, YC], axis=1)

    X[X<0]+=360

    return(X,Y)

def create_mask_from_latlon(X,Y,lon,lat):
    X = np.reshape(X, (np.size(X), 1))
    Y = np.reshape(Y, (np.size(Y), 1))
    mask = np.zeros_like(X)
    last_index = -100000000
    counter = 0
    for ll in range(len(lon)):
        dist = ((X - lon[ll]) ** 2 + (Y - lat[ll]) ** 2) ** 0.5
        index = np.argmin(dist)
        if index != last_index:
            counter += 1
            last_index = index
            mask[index] = counter
    return(mask)

def create_south_pole_mask(X,Y):

    mask = np.zeros_like(X)
    counter = 0
    for i in range(1,31):
        for j in range(1,31):
            counter +=1
            mask[i,5,j] = counter
    mask = np.reshape(mask, (np.size(mask), 1))
    return(mask)


input_dir = os.getcwd()

X,Y = read_cs32_faces(input_dir)

# create the equator mask
lon = np.arange(360)
lat = np.zeros_like(lon)
mask = create_mask_from_latlon(X,Y,lon,lat)
output_file = input_dir + '/equator_mask.bin'
mask.astype('>f8').tofile(output_file)
print('    Equator mask contains '+str(np.sum(mask>0))+' points')

X,Y = read_cs32_faces(input_dir)

# create the south pole mask
mask = create_south_pole_mask(X,Y)
output_file = input_dir + '/south_pole_mask.bin'
mask.astype('>f8').tofile(output_file)
print('    South pole mask contains '+str(np.sum(mask>0))+' points')
