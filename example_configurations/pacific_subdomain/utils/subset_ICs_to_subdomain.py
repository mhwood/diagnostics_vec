import numpy as np
import matplotlib.pyplot as plt

model_config = 'global_ocean'
sub_model_config = 'pacific_subdomain'
config_dir='../..'

#time, depth, rows, cols
field_size = (12,15,40,90)

def read_surface_mask(config_dir,model_config,surface_mask_name,field_size):
    arr = np.fromfile(config_dir+'/'+model_config + '/input/' + surface_mask_name, dtype='>f4')
    arr = np.reshape(arr,(field_size[2],field_size[3]))
    return(arr)


def read_file_to_subset(config_dir,model_config,field_file_name,field_size, has_time = True, has_depth=False):
    arr = np.fromfile(config_dir + '/' + model_config + '/input/' + field_file_name, dtype='>f4')
    if has_time and has_depth:
        arr = np.reshape(arr,field_size)
    elif has_time and not has_depth:
        arr = np.reshape(arr,(field_size[0],field_size[2],field_size[3]))
    elif not has_time and has_depth:
        arr = np.reshape(arr,(field_size[1],field_size[2],field_size[3]))
    else:
        arr = np.reshape(arr, (field_size[2], field_size[3]))
    arr = arr.astype(float)
    return(arr)


def subset_field_on_mask(field,var,surface_mask,has_time = True, has_depth=False):
    mask_rows,mask_cols = np.where(surface_mask>0)
    min_row = np.min(mask_rows)
    max_row = np.max(mask_rows)
    min_col = np.min(mask_cols)
    max_col = np.max(mask_cols)

    #print(min_row,max_row,min_col,max_col)

    if field == 'zonalWindFile':
        OLx = 2
        var = var[:,min_row:max_row+1,min_col+1-OLx:max_col+1+OLx]
    elif field == 'meridWindFile':
        OLy = 2
        var = var[:,min_row-1:max_row+3,min_col:max_col+1]
    else:
        if has_time and has_depth:
            var = var[:,:,min_row:max_row+1,min_col:max_col+1]
        elif has_time and not has_depth:
            var = var[:,min_row:max_row+1,min_col:max_col+1]
        elif not has_time and has_depth:
            var = var[:,min_row:max_row+1,min_col:max_col+1]
        else:
            var = var[min_row:max_row+1,min_col:max_col+1]

    return(var)

# step 1: read in the surface mask
surface_mask = read_surface_mask(config_dir,model_config,'surface_mask.bin',field_size)

fields = ['bathyFile','hydrogThetaFile','hydrogSaltFile','zonalWindFile','meridWindFile','thetaClimFile','saltClimFile','surfQnetFile','EmPmRFile']
field_to_file= {  'bathyFile': 'bathymetry.bin',
                  'hydrogThetaFile' : 'lev_t.bin',
                  'hydrogSaltFile' : 'lev_s.bin',
                  'zonalWindFile' :  'trenberth_taux.bin',
                  'meridWindFile' :  'trenberth_tauy.bin',
                  'thetaClimFile' :  'lev_sst.bin',
                  'saltClimFile' :   'lev_sss.bin',
                  'surfQnetFile' :   'ncep_qnet.bin',
                  'EmPmRFile' :      'ncep_emp.bin' }

for field in fields:
    # step 2: read in the file
    field_file_name = field_to_file[field]
    if field in ['hydrogThetaFile','hydrogSaltFile']:
        has_time = True
        has_depth = True
    elif field in ['bathyFile']:
        has_time = False
        has_depth = False
    else:
        has_time = True
        has_depth = False
    var = read_file_to_subset(config_dir,model_config,field_file_name,field_size,has_time,has_depth)

    # step 3: subset file on submask indices
    var = subset_field_on_mask(field,var, surface_mask, has_time, has_depth)

    # step 4: output file to model_config_domain
    output_file_name = field_file_name.split('.')[0]+'_pacific.bin'
    output_file_path = config_dir+'/'+sub_model_config+'/input/'+output_file_name
    var.ravel(order='C').astype('>f4').tofile(output_file_path)

    # if field in ['hydrogThetaFile', 'hydrogSaltFile']:
    #     plt.imshow(var[0,0,:,:])
    # elif field in ['bathyFile']:
    #     plt.imshow(var)
    # else:
    #     plt.imshow(var[0,:,:])
    # plt.title(field)
    # plt.show()

# for field in ['bathyFile','hydrogThetaFile','hydrogSaltFile','zonalWindFile','meridWindFile',
#               'thetaClimFile','saltClimFile','surfQnetFile','EmPmRFile']:
#     arr = np.fromfile(directory+'/input/'+field_to_file[field], dtype='>f4')
#     print(' Field = '+field)
#     if field in ['hydrogThetaFile','hydrogSaltFile']:
#         print('    len = '+str(len(arr))+' mod 90*40*15 = '+str(len(arr)/(90*40*15)))
#     else:
#         print('    len = ' + str(len(arr)) + ' mod 90*40 = ' + str(len(arr) / (90 * 40)))