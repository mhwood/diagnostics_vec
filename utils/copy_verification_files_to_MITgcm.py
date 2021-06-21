
import os
import shutil
import argparse

######################################################################
# This function is to add the new verification components

def add_to_verification_experiments(mitgcm_path,create_compile_scripts):
    experiment_names = ['global_ocean.cs32x15','global_with_exf']
    for experiment_name in experiment_names:
        print('Adding new confirguration to '+experiment_name)

        if experiment_name=='global_ocean.cs32x15':
            if 'input_dv.seaice' in os.listdir(os.path.join(mitgcm_path,'verification',experiment_name)):
                shutil.rmtree(os.path.join(mitgcm_path,'verification',experiment_name,'input_dv.seaice'))
            os.mkdir(os.path.join(mitgcm_path,'verification',experiment_name,'input_dv.seaice'))
        if experiment_name=='global_with_exf':
            if 'input_dv' in os.listdir(os.path.join(mitgcm_path,'verification',experiment_name)):
                shutil.rmtree(os.path.join(mitgcm_path,'verification',experiment_name,'input_dv'))
            os.mkdir(os.path.join(mitgcm_path,'verification',experiment_name,'input_dv'))
        if 'code_dv' in os.listdir(os.path.join(mitgcm_path,'verification',experiment_name)):
            shutil.rmtree(os.path.join(mitgcm_path,'verification',experiment_name,'code_dv'))
        os.mkdir(os.path.join(mitgcm_path,'verification',experiment_name,'code_dv'))

        for subdir in ['input_dv.seaice','code_dv','input_dv']:
            if subdir in os.listdir(os.path.join('..','verification',experiment_name)):
                for file_name in os.listdir(os.path.join('..','verification',experiment_name,subdir)):
                    # os.symlink(os.path.join('..', 'verification', experiment_name, file_name,sub_file_name),
                    #            os.path.join(mitgcm_path, 'verification', experiment_name, file_name,sub_file_name))
                    shutil.copyfile(os.path.join('..', 'verification', experiment_name, subdir, file_name),
                               os.path.join(mitgcm_path, 'verification', experiment_name, subdir, file_name))

        if create_compile_scripts:
            build_text = 'cd build'
            build_text += '\n../../../tools/genmake2 -mods ../code_dv -optfile ../../../tools/build_options/darwin_amd64_gfortran_mw'
            build_text += '\nmake depend'
            build_text += '\nmake'
            build_text += '\ncd ..'
            f = open(os.path.join(mitgcm_path,'verification',experiment_name,'build_dv.sh'),'w')
            f.write(build_text)
            f.close()

            build_text = 'cd build'
            build_text += '\n../../../tools/genmake2 -mods ../code_dv -mpi -optfile ../../../tools/build_options/darwin_amd64_gfortran_mw'
            build_text += '\nmake depend'
            build_text += '\nmake'
            build_text += '\ncd ..'
            f = open(os.path.join(mitgcm_path, 'verification', experiment_name, 'build_dv_mpi.sh'), 'w')
            f.write(build_text)
            f.close()

            run_text = 'rm run/*'
            run_text += '\ncd run'
            if experiment_name == 'global_ocean.cs32x15':
                run_text += '\nln -s ../input_dv.seaice/* .'
            if experiment_name == 'global_with_exf':
                run_text += '\nln -s ../input_dv/* .'
            run_text += '\ncp ../build/mitgcmuv .'
            run_text += '\n./mitgcmuv > output.txt'
            f = open(os.path.join(mitgcm_path, 'verification', experiment_name, 'run_dv.sh'), 'w')
            f.write(run_text)
            f.close()

            run_text = '\nrm run/*'
            run_text += '\ncd run'
            run_text += '\nln -s ../input_dv.seaice/* .'
            if experiment_name == 'global_with_exf':
                run_text += '\nln -s ../input_dv/* .'
                run_text += '\nmpirun -np 2 ../build/mitgcmuv'
            if experiment_name == 'global_ocean.cs32x15':
                run_text += '\nln -s ../input_dv.seaice/* .'
                run_text += '\nmpirun -np 4 ../build/mitgcmuv'
            f = open(os.path.join(mitgcm_path, 'verification', experiment_name, 'run_dv_mpi.sh'), 'w')
            f.write(run_text)
            f.close()

######################################################################
# This function is the main utility

def copy_files_to_fresh_clone(mitgcm_path,create_compile_scripts):
    pwd = os.getcwd()
    pwd_short = pwd.split(os.path.sep)[-1]
    if pwd_short!='utils':
        raise ValueError('Run this code from within the utils dir')

    # step 1: add the verification experiments
    print('Updating the verification experiments')
    add_to_verification_experiments(mitgcm_path,create_compile_scripts)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument("-m", "--mitgcm_directory", action="store",
                        help="Path to the MITgcm directory.", dest="mitgcm_path",
                        type=str, required=True)

    parser.add_argument("-c", "--compile", action="store",
                        help="Boolean option to create build and compile codes", dest="compile",
                        type=int, required=False, default=0)

    args = parser.parse_args()
    mitgcm_path = args.mitgcm_path
    compile = args.compile

    if compile==1:
        create_compile_scripts = True
    else:
        create_compile_scripts = False

    copy_files_to_fresh_clone(mitgcm_path,create_compile_scripts)

