import os
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

Nx = 90
Ny = 40

lateral_mask_names = ['lateral_mask_south','lateral_mask_north',
              'lateral_mask_west','lateral_mask_east']

# collect the mask files
lateral_mask_grids = []
for mask_name in lateral_mask_names:
    mask_file = os.path.join('..','input',mask_name+'.bin')
    mask_grid = np.fromfile(mask_file,dtype='>f4')
    mask_grid = np.reshape(mask_grid,(Ny,Nx))
    lateral_mask_grids.append(mask_grid)
surface_mask_file = os.path.join('..','input','surface_mask.bin')
surface_mask_grid = np.fromfile(surface_mask_file,dtype='>f4')
surface_mask_grid = np.reshape(surface_mask_grid,(Ny,Nx))

# read the bathymetry
bathy_file = os.path.join('..','input','bathymetry.bin')
bathy_grid = np.fromfile(bathy_file,dtype='>f4')
bathy_grid = np.reshape(bathy_grid,(Ny,Nx))

# plot the masks on the bathymetry
fig = plt.figure()
mask_plot_colors = ['red','orange','green','purple']

plt.subplot(2,1,1)
plt.title('Lateral Masks')
C = plt.imshow(bathy_grid,origin='lower',cmap='Blues_r')
cbar = plt.colorbar(C)
cbar.set_label('Bathymetry (m)')
for mn in range(len(lateral_mask_grids)):
    rows,cols = np.where(lateral_mask_grids[mn]!=0)
    for pt in range(len(rows)):
        rect = Rectangle((cols[pt],rows[pt]),1,1,color=mask_plot_colors[mn])
        plt.gca().add_patch(rect)
plt.text(45,5,'lateral mask south',color=mask_plot_colors[0],ha='center',va='center',
         bbox=dict(boxstyle="round",ec=mask_plot_colors[0],fc='w'))
plt.text(45,35,'lateral mask north',color=mask_plot_colors[1],ha='center',va='center',
         bbox=dict(boxstyle="round",ec=mask_plot_colors[1],fc='w'))
plt.text(23,20,'lateral mask\nwest',color=mask_plot_colors[2],ha='right',va='center',
         bbox=dict(boxstyle="round",ec=mask_plot_colors[2],fc='w'))
plt.text(69,20,'lateral mask\neast',color=mask_plot_colors[3],ha='left',va='center',
         bbox=dict(boxstyle="round",ec=mask_plot_colors[3],fc='w'))

plt.gca().set_xticks([])
plt.gca().set_yticks([])

plt.subplot(2,1,2)
plt.title('Surface Mask')
C = plt.imshow(bathy_grid,origin='lower',cmap='Blues_r')
cbar = plt.colorbar(C)
cbar.set_label('Bathymetry (m)')
rows,cols = np.where(surface_mask_grid!=0)
rect = Rectangle((np.min(cols),np.min(rows)),
                 np.max(cols)-np.min(cols),np.max(rows)-np.min(rows),
                 color='red',hatch='//',fill=False)
plt.gca().add_patch(rect)
plt.text(45,20,'surface mask',color='red',ha='center',va='center',
         bbox=dict(boxstyle="round",ec='red',fc='w'))

plt.gca().set_xticks([])
plt.gca().set_yticks([])

output_file = os.path.join('..','plots','diagnostic_vec_masks.png')
plt.savefig(output_file,bbox_inches='tight')
plt.close(fig)

print('Output file to '+output_file)

