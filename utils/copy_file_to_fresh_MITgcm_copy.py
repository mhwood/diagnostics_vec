
import os
import shutil
import argparse

def replace_boot_sequence_files(mitgcm_path,pwd):
    for file_name in os.listdir(os.path.join(pwd,'model','src')):
        if file_name[-1]=='F':
            if file_name in os.listdir(os.path.join(mitgcm_path,'model','src')):
                os.remove(os.path.join(mitgcm_path,'model','src',file_name))
            # if mod_option == 's':
            os.symlink(os.path.join(pwd,'model','src',file_name),os.path.join(mitgcm_path,'model','src',file_name))
        if file_name[-1]=='h':
            if file_name in os.listdir(os.path.join(mitgcm_path, 'model', 'inc')):
                os.remove(os.path.join(mitgcm_path, 'model', 'inc', file_name))
            # if mod_option == 's':
            os.symlink(os.path.join(pwd,'model','inc',file_name),os.path.join(mitgcm_path,'model','inc',file_name))

    for file_name in os.listdir(os.path.join(pwd,'model','inc')):
        if file_name[-1]=='h':
            if file_name in os.listdir(os.path.join(mitgcm_path, 'model', 'inc')):
                os.remove(os.path.join(mitgcm_path, 'model', 'inc', file_name))
            # if mod_option == 's':
            os.symlink(os.path.join(pwd,'model','inc',file_name),os.path.join(mitgcm_path,'model','inc',file_name))

def add_diagnostics_vec_package_files(mitgcm_path,pwd):
    if 'diagnostics_vec' in os.listdir(os.path.join(mitgcm_path,'pkg')):
        shutil.rmtree(os.path.join(mitgcm_path,'pkg','diagnostics_vec'))
    os.mkdir(os.path.join(mitgcm_path,'pkg','diagnostics_vec'))
    for file_name in os.listdir(os.path.join(pwd,'pkg','diagnostics_vec')):
        if file_name[-1]=='F':
            # if mod_option == 's':
            os.symlink(os.path.join(pwd,'pkg','diagnostics_vec',file_name),os.path.join(mitgcm_path,'pkg','diagnostics_vec',file_name))
        if file_name[-1]=='h':
            # if mod_option == 's':
            os.symlink(os.path.join(pwd,'pkg','diagnostics_vec',file_name),os.path.join(mitgcm_path,'pkg','diagnostics_vec',file_name))

def add_to_verification_experiments(mitgcm_path,pwd):
    experiment_names = ['global_with_exf_diagnostics_vec','global_ocean.cs32x15_diagnostics_vec']
    for experiment_name in experiment_names:
        if experiment_name in os.listdir(os.path.join(mitgcm_path,'verification')):
            shutil.rmtree(os.path.join(mitgcm_path,'verification',experiment_name))
        os.mkdir(os.path.join(mitgcm_path,'verification',experiment_name))
        for file_name in os.listdir(os.path.join(pwd,'verification',experiment_name)):
            if file_name=='README':
                if mod_option == 's':
                    os.symlink(os.path.join(pwd, 'verification', experiment_name, file_name),
                               os.path.join(mitgcm_path, 'verification', experiment_name, file_name))
            elif file_name in ['build','code','input','plots','results','run','utils']:
                os.mkdir(os.path.join(mitgcm_path, 'verification', experiment_name, file_name))
                for sub_file_name in os.listdir(os.path.join(pwd, 'verification', experiment_name, file_name)):
                    if mod_option == 's':
                        os.symlink(os.path.join(pwd, 'verification', experiment_name, file_name,sub_file_name),
                                   os.path.join(mitgcm_path, 'verification', experiment_name, file_name,sub_file_name))
            else:
                a=1

        build_text = 'cd build'
        build_text += '\n../../../tools/genmake2 -mods ../code -optfile ../../../tools/build_options/darwin_amd64_gfortran'
        build_text += '\nmake depend'
        build_text += '\nmake'
        build_text += '\ncd ..'
        f = open(os.path.join(mitgcm_path,'verification',experiment_name,'build.sh'),'w')
        f.write(build_text)
        f.close()

        build_text = 'cd build'
        build_text += '\n../../../tools/genmake2 -mods ../code -mpi -optfile ../../../tools/build_options/darwin_amd64_gfortran'
        build_text += '\nmake depend'
        build_text += '\nmake'
        build_text += '\ncd ..'
        f = open(os.path.join(mitgcm_path, 'verification', experiment_name, 'build_mpi.sh'), 'w')
        f.write(build_text)
        f.close()

        run_text = 'rm -r run/mnc*'
        run_text += '\nrm run/*'
        run_text += '\ncd run'
        run_text += '\nln -s ../input/* .'
        run_text += '\ncp ../build/mitgcmuv .'
        run_text += '\n./mitgcmuv > output.txt'
        f = open(os.path.join(mitgcm_path, 'verification', experiment_name, 'run.sh'), 'w')
        f.write(run_text)
        f.close()

        run_text = 'rm -r run/mnc*'
        run_text += '\nrm run/*'
        run_text += '\ncd run'
        run_text += '\nln -s ../input/* .'
        if experiment_name == 'global_with_exf_diagnostics_vec':
            run_text += '\nmpirun -np 2 ../build/mitgcmuv'
        if experiment_name == 'global_ocean.cs32x15_diagnostics_vec':
            run_text += '\nmpirun -np 4 ../build/mitgcmuv'
        f = open(os.path.join(mitgcm_path, 'verification', experiment_name, 'run_mpi.sh'), 'w')
        f.write(run_text)
        f.close()

mitgcm_path = '/Users/mhwood/Documents/Research/Projects/Ocean_Modeling/MITgcm_fresh'


def copy_files_to_fresh_clone(mitgcm_path,mod_option='s'):
    pwd = os.getcwd()

    # step 1: remove the old boot sequence files and add the new ones
    replace_boot_sequence_files(mitgcm_path,pwd)

    # step 2: add the new diagnostics_vec_package
    add_diagnostics_vec_package_files(mitgcm_path,pwd)

    # step 3: add the verification experiments
    add_to_verification_experiments(mitgcm_path,pwd)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()


    parser.add_argument("-m", "--mitgcm_directory", action="store",
                        help="Path to the MITgcm directory.", dest="mitgcm_path",
                        type=str, required=True)

    args = parser.parse_args()
    mitgcm_path = args.mitgcm_path
    copy_files_to_fresh_clone(mitgcm_path)

    resample_GLISTIN_DEMs(dataFolder,years,fileIndices,resolution,projection,addGeoid=addGeoid,addMetadata=addMetadata)

