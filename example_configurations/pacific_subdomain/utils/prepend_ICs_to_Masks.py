import os
import numpy as np
import matplotlib.pyplot as plt
from MITgcmutils import mds

min_col = 27
max_col = 63
min_row = 18
max_row = 33

Nr = 15
n_timesteps = 366

field_size = (12,15,40,90)

global_folder = '../../global_ocean'
subdomain_input_folder = '../input'

def read_IC_subset(global_folder,var_name,field_size,mod_mask_number,
                    min_col,max_col,min_row,max_row):
    if var_name == 'T':
        field_file_name='T*'
    if var_name == 'S':
        field_file_name='S*'

    arr = mds.rdmds(global_folder + '/run/'+field_file_name,0)

    if mod_mask_number == 1:
        IC = arr[:,min_row,min_col:max_col+1]
    if mod_mask_number == 2:
        IC = arr[:,min_row:max_row+1,max_col]
    if mod_mask_number == 3:
        IC = arr[:,max_row,min_col:max_col+1]
    if mod_mask_number == 0:
        IC = arr[:,min_row:max_row+1,min_col]

    return(IC)

var_ob_names = {'T':'THETA','S':'SALT','U':'UVEL','V':'VVEL','W':'WVEL','Eta':'ETAN'}

var_names = ['T','S','U','V','W']
mask_numbers = [1,2,3,4]

# load the initial conditions
for var_name in var_names:
    for ob_mask_number in mask_numbers:
        var_ob_name = var_ob_names[var_name]

        mask_output_file = 'MASK_OB_'+'{:02d}'.format(ob_mask_number)+'_'+var_ob_name+'.bin'

        mod_mask_number = ob_mask_number%4
        if mod_mask_number==1:
            if var_name=='Eta':
                # 2d var
                diag_ob_var = np.fromfile(global_folder+'/run/'+mask_output_file, dtype='>f4')
                diag_ob_var = np.reshape(diag_ob_var,(n_timesteps,max_col-min_col+1))
                new_diag_ob_var = np.zeros((np.shape(diag_ob_var)[0]+1,np.shape(diag_ob_var)[1]))
                new_diag_ob_var[1:,:]=diag_ob_var
                new_diag_ob_var.ravel(order='C').astype('>f4').tofile(subdomain_input_folder+'/'+mask_output_file)
            else:
                # 3 vars
                diag_ob_var = np.fromfile(global_folder+'/run/'+mask_output_file, dtype='>f4')
                diag_ob_var = np.reshape(diag_ob_var,(n_timesteps,Nr,max_col-min_col+1))
                new_diag_ob_var = np.zeros((np.shape(diag_ob_var)[0]+1,np.shape(diag_ob_var)[1],np.shape(diag_ob_var)[2]))
                new_diag_ob_var[1:,:,:]=diag_ob_var
                if var_name in ['T','S']:
                    var_IC = read_IC_subset(global_folder,var_name,field_size,mod_mask_number,
                                                min_col,max_col,min_row,max_row)
                    new_diag_ob_var[0,:,:] = var_IC
                new_diag_ob_var.ravel(order='C').astype('>f4').tofile(subdomain_input_folder+'/'+mask_output_file)
        if mod_mask_number==2:
            if var_name=='Eta':
                # 2d var
                diag_ob_var = np.fromfile(global_folder+'/run/'+mask_output_file, dtype='>f4')
                diag_ob_var = np.reshape(diag_ob_var,(n_timesteps,max_row-min_row+1))
                new_diag_ob_var = np.zeros((np.shape(diag_ob_var)[0]+1,np.shape(diag_ob_var)[1]))
                new_diag_ob_var[1:,:]=diag_ob_var
                new_diag_ob_var.ravel(order='C').astype('>f4').tofile(subdomain_input_folder+'/'+mask_output_file)
            else:
                # 3 vars
                diag_ob_var = np.fromfile(global_folder+'/run/'+mask_output_file, dtype='>f4')
                diag_ob_var = np.reshape(diag_ob_var,(n_timesteps,Nr,max_row-min_row+1))
                new_diag_ob_var = np.zeros((np.shape(diag_ob_var)[0]+1,np.shape(diag_ob_var)[1],np.shape(diag_ob_var)[2]))
                new_diag_ob_var[1:,:,:]=diag_ob_var
                if var_name in ['T','S']:
                    var_IC = read_IC_subset(global_folder,var_name,field_size,mod_mask_number,
                                                min_col,max_col,min_row,max_row)
                    new_diag_ob_var[0,:,:] = var_IC
                new_diag_ob_var.ravel(order='C').astype('>f4').tofile(subdomain_input_folder+'/'+mask_output_file)
        if mod_mask_number==3:
            if var_name=='Eta':
                # 2d var
                diag_ob_var = np.fromfile(global_folder+'/run/'+mask_output_file, dtype='>f4')
                diag_ob_var = np.reshape(diag_ob_var,(n_timesteps,max_col-min_col+1))
                new_diag_ob_var = np.zeros((np.shape(diag_ob_var)[0]+1,np.shape(diag_ob_var)[1]))
                new_diag_ob_var[1:,:]=diag_ob_var
                new_diag_ob_var.ravel(order='C').astype('>f4').tofile(subdomain_input_folder+'/'+mask_output_file)
            else:
                # 3 vars
                diag_ob_var = np.fromfile(global_folder+'/run/'+mask_output_file, dtype='>f4')
                diag_ob_var = np.reshape(diag_ob_var,(n_timesteps,Nr,max_col-min_col+1))
                new_diag_ob_var = np.zeros((np.shape(diag_ob_var)[0]+1,np.shape(diag_ob_var)[1],np.shape(diag_ob_var)[2]))
                new_diag_ob_var[1:,:,:]=diag_ob_var
                if var_name in ['T','S']:
                    var_IC = read_IC_subset(global_folder,var_name,field_size,mod_mask_number,
                                                min_col,max_col,min_row,max_row)
                    new_diag_ob_var[0,:,:] = var_IC
                new_diag_ob_var.ravel(order='C').astype('>f4').tofile(subdomain_input_folder+'/'+mask_output_file)
        if mod_mask_number==0:
            if var_name=='Eta':
                # 2d var
                diag_ob_var = np.fromfile(global_folder+'/run/'+mask_output_file, dtype='>f4')
                diag_ob_var = np.reshape(diag_ob_var,(n_timesteps,max_row-min_row+1))
                new_diag_ob_var = np.zeros((np.shape(diag_ob_var)[0]+1,np.shape(diag_ob_var)[1]))
                new_diag_ob_var[1:,:]=diag_ob_var
                new_diag_ob_var.ravel(order='C').astype('>f4').tofile(subdomain_input_folder+'/'+mask_output_file)
            else:
                # 3 vars
                diag_ob_var = np.fromfile(global_folder+'/run/'+mask_output_file, dtype='>f4')
                diag_ob_var = np.reshape(diag_ob_var,(n_timesteps,Nr,max_row-min_row+1))
                new_diag_ob_var = np.zeros((np.shape(diag_ob_var)[0]+1,np.shape(diag_ob_var)[1],np.shape(diag_ob_var)[2]))
                new_diag_ob_var[1:,:,:]=diag_ob_var
                if var_name in ['T','S']:
                    var_IC = read_IC_subset(global_folder,var_name,field_size,mod_mask_number,
                                                min_col,max_col,min_row,max_row)
                    new_diag_ob_var[0,:,:] = var_IC
                new_diag_ob_var.ravel(order='C').astype('>f4').tofile(subdomain_input_folder+'/'+mask_output_file)

        # plt.subplot(3,1,1)
        # plt.imshow(new_diag_ob_var[0,:,:])
        # plt.subplot(3,1,2)
        # plt.imshow(new_diag_ob_var[1,:,:])
        # plt.subplot(3,1,3)
        # C=plt.imshow(new_diag_ob_var[1,:,:]-new_diag_ob_var[0,:,:])
        # plt.colorbar(C)
        # plt.show()

    
