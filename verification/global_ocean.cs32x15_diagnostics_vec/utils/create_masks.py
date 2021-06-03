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

def create_mask(X,Y,lon,lat):
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


# mask boundaries
min_lon = 120
max_lon = 240
min_lat = -10
max_lat = 30

input_dir = os.path.join('..','input')

mask_names = ['lateral_mask_south','lateral_mask_north',
              'lateral_mask_east','lateral_mask_west']

X,Y = read_cs32_faces(input_dir)

for mask_name in mask_names:
    print('Creating '+mask_name)
    if mask_name=='lateral_mask_south':
        lon = np.arange(min_lon, max_lon + 1)
        lat = min_lat * np.ones_like(lon)
    if mask_name=='lateral_mask_north':
        lon = np.arange(min_lon, max_lon + 1)
        lat = max_lat * np.ones_like(lon)
    if mask_name=='lateral_mask_east':
        lat = np.arange(min_lat, max_lat + 1)
        lon = max_lon * np.ones_like(lat)
    if mask_name=='lateral_mask_west':
        lat = np.arange(min_lat, max_lat + 1)
        lon = min_lon * np.ones_like(lat)
    mask = create_mask(X,Y,lon,lat)
    output_file = input_dir + '/'+mask_name+'.bin'
    mask.astype('>f8').tofile(output_file)
    print('    Mask contains '+str(np.sum(mask>0))+' points')