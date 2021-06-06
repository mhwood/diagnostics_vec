
import os
import shutil
import argparse

######################################################################
# All of these functions are for adding the pkg into the boot sequence

def add_new_lines(lines,indicator,skip_line,add_lines):
    for ll in range(len(lines)):
        line = lines[ll]
        if line[:len(indicator)] == indicator:
            line_split_number = ll + skip_line + 1
    new_lines = lines[:line_split_number] + add_lines + lines[line_split_number:]
    return(new_lines)

def update_PARAMS(inc_dir):
    f=open(os.path.join(inc_dir,'PARAMS.h'))
    lines = f.read()
    f.close()
    lines = lines.split('\n')

    # add the note to the chain
    indicator = '      LOGICAL useDiagnostics'
    skip_line = 0
    add_lines = ['      LOGICAL useDiagnostics_vec']
    lines = add_new_lines(lines, indicator, skip_line, add_lines)

    # add the note to the chain
    indicator = '     &        useDiagnostics, useREGRID, useLayers, useMNC,'
    skip_line = 0
    add_lines = ['     &        useDiagnostics_vec,']
    lines = add_new_lines(lines, indicator, skip_line, add_lines)

    output = '\n'.join(lines)
    g = open(os.path.join(inc_dir,'PARAMS.h'),'w')
    g.write(output)
    g.close()

def update_packages_boot(src_dir):
    f=open(os.path.join(src_dir,'packages_boot.F'))
    lines = f.read()
    f.close()
    lines = lines.split('\n')

    # add the note to the chain
    indicator = '     &          useDiagnostics,'
    skip_line = 0
    add_lines = ['     &          useDiagnostics_vec,']
    lines = add_new_lines(lines, indicator, skip_line, add_lines)

    # add the note to the chain
    indicator = '      useDiagnostics  =.FALSE.'
    skip_line = 0
    add_lines = ['      useDiagnostics_vec =.FALSE.']
    lines = add_new_lines(lines, indicator, skip_line, add_lines)

    # add the check code
    indicator = '      CALL PACKAGES_PRINT_MSG( useDiagnostics'
    skip_line = 1
    add_lines = ['#ifdef ALLOW_DIAGNOSTICS_VEC',
                 '      CALL PACKAGES_PRINT_MSG( useDiagnostics_vec,',
                 '     &                         \'Diagnostics_vec\', \' \' )',
                 '#endif']
    lines = add_new_lines(lines, indicator, skip_line, add_lines)

    output = '\n'.join(lines)
    g = open(os.path.join(src_dir,'packages_boot.F'),'w')
    g.write(output)
    g.close()

def update_packages_check(src_dir):
    f=open(os.path.join(src_dir,'packages_check.F'))
    lines = f.read()
    f.close()
    lines = lines.split('\n')

    # add the note to the chain
    indicator = 'C       |-- DIAGNOSTICS_CHECK'
    skip_line = 1
    add_lines = ['C       |-- DIAGNOSTICS_VEC_CHECK','C       |']
    lines = add_new_lines(lines, indicator, skip_line, add_lines)

    # add the check code
    indicator = '     &   CALL PACKAGES_ERROR_MSG( \'Diagnostics\', \' \', myThid )'
    skip_line = 1
    add_lines = ['',
                 '#ifdef ALLOW_DIAGNOSTICS_VEC',
                 '      IF (useDiagnostics_vec) CALL DIAGNOSTICS_VEC_CHECK( myThid )',
                 '#else',
                 '      IF (useDiagnostics_vec)',
                 '     & CALL PACKAGES_ERROR_MSG(\'Diagnostics_vec\',\' \',myThid)',
                 '#endif']
    lines = add_new_lines(lines, indicator, skip_line, add_lines)

    output = '\n'.join(lines)
    g = open(os.path.join(src_dir,'packages_check.F'),'w')
    g.write(output)
    g.close()

def update_packages_init_fixed(src_dir):
    f=open(os.path.join(src_dir,'packages_init_fixed.F'))
    lines = f.read()
    f.close()
    lines = lines.split('\n')

    # add the note to the chain
    indicator = 'C       |-- CTRL_ADMTLM'
    skip_line = 1
    add_lines = ['C       |-- DIAGNOSTICS_VEC_INIT_FIXED','C       |']
    lines = add_new_lines(lines, indicator, skip_line, add_lines)

    # add the check code
    indicator = '        CALL CTRL_ADMTLM( myThid )'
    skip_line = 3
    add_lines = ['',
                 '#ifdef ALLOW_DIAGNOSTICS_VEC',
                 '      IF (useDiagnostics_vec) THEN',
                 '# ifdef ALLOW_DEBUG',
                 '        IF (debugMode)',
                 '     & CALL DEBUG_CALL(\'DIAGNOSTICS_VEC_INIT_FIXED\',myThid)',
                 '# endif',
                 '        CALL DIAGNOSTICS_VEC_INIT_FIXED( myThid )',
                 '      ENDIF',
                 '#endif',]
    lines = add_new_lines(lines, indicator, skip_line, add_lines)

    output = '\n'.join(lines)
    g = open(os.path.join(src_dir,'packages_init_fixed.F'),'w')
    g.write(output)
    g.close()

def update_packages_init_variables(src_dir):
    f=open(os.path.join(src_dir,'packages_init_variables.F'))
    lines = f.read()
    f.close()
    lines = lines.split('\n')

    # add the note to the chain
    indicator = 'C       |-- DIAGNOSTICS_INIT_VARIA'
    skip_line = 0
    add_lines = ['C       |','C       |-- DIAGNOSTICS_VEC_INIT_VARIA']
    lines = add_new_lines(lines, indicator, skip_line, add_lines)

    # add the check code
    indicator = '        CALL DIAGNOSTICS_INIT_VARIA( myThid )'
    skip_line = 2
    add_lines = ['',
                 '#ifdef ALLOW_DIAGNOSTICS_VEC',
                 '      IF (useDiagnostics_vec) THEN',
                 '# ifdef ALLOW_DEBUG',
                 '        IF (debugMode)',
                 '     & CALL DEBUG_CALL(\'DIAGNOSTICS_VEC_INIT_VARIA\',myThid)',
                 '# endif',
                 '        CALL DIAGNOSTICS_VEC_INIT_VARIA( myThid )',
                 '      ENDIF',
                 '#endif',]
    lines = add_new_lines(lines, indicator, skip_line, add_lines)

    output = '\n'.join(lines)
    g = open(os.path.join(src_dir,'packages_init_variables.F'),'w')
    g.write(output)
    g.close()

def update_packages_readparms(src_dir):
    f=open(os.path.join(src_dir,'packages_readparms.F'))
    lines = f.read()
    f.close()
    lines = lines.split('\n')

    # add the note to the chain
    indicator = 'C       |-- DIAGNOSTICS_READPARMS'
    skip_line = 0
    add_lines = ['C       |','C       |-- DIAGNOSTICS_VEC_READPARMS']
    lines = add_new_lines(lines, indicator, skip_line, add_lines)

    # add the check code
    indicator = '      CALL DIAGNOSTICS_READPARMS( myThid )'
    skip_line = 1
    add_lines = ['',
                 '#ifdef ALLOW_DIAGNOSTICS_VEC',
                 'C--   if useDiagnostics_vec=T, set DIAGNOSTICS_VEC parameters; otherwise just return',
                 '      CALL DIAGNOSTICS_VEC_READPARMS( myThid )',
                 '#endif']
    lines = add_new_lines(lines, indicator, skip_line, add_lines)

    output = '\n'.join(lines)
    g = open(os.path.join(src_dir,'packages_readparms.F'),'w')
    g.write(output)
    g.close()

def update_do_the_model_io(src_dir):
    f=open(os.path.join(src_dir,'do_the_model_io.F'))
    lines = f.read()
    f.close()
    lines = lines.split('\n')

    # add the note to the chain
    indicator = 'C       |-- LAYERS_OUTPUT'
    skip_line = 0
    add_lines = ['C       |','C       |-- DIAGNOSTICS_VEC_OUTPUT']
    lines = add_new_lines(lines, indicator, skip_line, add_lines)

    # add the check code
    indicator = '        CALL LAYERS_OUTPUT( myTime, myIter, myThid )'
    skip_line = 2
    add_lines = ['',
                 '#ifdef ALLOW_DIAGNOSTICS_VEC',
                 '      IF ( useDiagnostics_vec )',
                 '     &     CALL DIAGNOSTICS_VEC_OUTPUT( myTime, myIter, myThid )',
                 '#endif']
    lines = add_new_lines(lines, indicator, skip_line, add_lines)

    output = '\n'.join(lines)
    g = open(os.path.join(src_dir,'do_the_model_io.F'),'w')
    g.write(output)
    g.close()

def update_boot_sequence_files(mitgcm_path):

    inc_dir = os.path.join(mitgcm_path,'model','inc')
    src_dir = os.path.join(mitgcm_path, 'model', 'src')

    update_PARAMS(inc_dir)
    update_packages_boot(src_dir)
    update_packages_check(src_dir)
    update_packages_init_fixed(src_dir)
    update_packages_init_variables(src_dir)
    update_packages_readparms(src_dir)
    update_do_the_model_io(src_dir)

######################################################################
# This function is to add the new package files to the pkg dir

def add_diagnostics_vec_package_files(mitgcm_path):

    src_dir = os.path.join('..','')

    if 'diagnostics_vec' in os.listdir(os.path.join(mitgcm_path,'pkg')):
        shutil.rmtree(os.path.join(mitgcm_path,'pkg','diagnostics_vec'))

    os.mkdir(os.path.join(mitgcm_path,'pkg','diagnostics_vec'))

    for file_name in os.listdir(os.path.join('..','pkg','diagnostics_vec')):
        if file_name[-1]=='F':
            # if mod_option == 's':
            #os.symlink(os.path.join(pwd,'pkg','diagnostics_vec',file_name),os.path.join(mitgcm_path,'pkg','diagnostics_vec',file_name))
            shutil.copyfile(os.path.join('..', 'pkg', 'diagnostics_vec', file_name),
                       os.path.join(mitgcm_path, 'pkg', 'diagnostics_vec', file_name))
        if file_name[-1]=='h':
            # if mod_option == 's':
            #os.symlink(os.path.join(pwd,'pkg','diagnostics_vec',file_name),os.path.join(mitgcm_path,'pkg','diagnostics_vec',file_name))
            shutil.copyfile(os.path.join('..', 'pkg', 'diagnostics_vec', file_name),
                       os.path.join(mitgcm_path, 'pkg', 'diagnostics_vec', file_name))

def add_to_verification_experiments(mitgcm_path,create_compile_scripts):
    experiment_names = ['global_ocean.cs32x15']#'global_with_exf
    for experiment_name in experiment_names:

        if 'input_dv.seaice' in os.listdir(os.path.join(mitgcm_path,'verification',experiment_name)):
            shutil.rmtree(os.path.join(mitgcm_path,'verification',experiment_name,'input_dv.seaice'))
        os.mkdir(os.path.join(mitgcm_path,'verification',experiment_name,'input_dv.seaice'))
        if 'code_dv' in os.listdir(os.path.join(mitgcm_path,'verification',experiment_name)):
            shutil.rmtree(os.path.join(mitgcm_path,'verification',experiment_name,'code_dv'))
        os.mkdir(os.path.join(mitgcm_path,'verification',experiment_name,'code_dv'))

        for subdir in ['input_dv.seaice','code_dv']:
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

            run_text = 'rm -r run/mnc*'
            run_text += '\nrm run/*'
            run_text += '\ncd run'
            run_text += '\nln -s ../input_dv.seaice/* .'
            run_text += '\ncp ../build/mitgcmuv .'
            run_text += '\n./mitgcmuv > output.txt'
            f = open(os.path.join(mitgcm_path, 'verification', experiment_name, 'run_dv.sh'), 'w')
            f.write(run_text)
            f.close()

            run_text = 'rm -r run/mnc*'
            run_text += '\nrm run/*'
            run_text += '\ncd run'
            run_text += '\nln -s ../input_dv.seaice/* .'
            if experiment_name == 'global_with_exf':
                run_text += '\nmpirun -np 2 ../build/mitgcmuv'
            if experiment_name == 'global_ocean.cs32x15':
                run_text += '\nmpirun -np 4 ../build/mitgcmuv'
            f = open(os.path.join(mitgcm_path, 'verification', experiment_name, 'run_dv_mpi.sh'), 'w')
            f.write(run_text)
            f.close()

mitgcm_path = '/Users/mhwood/Documents/Research/Projects/Ocean_Modeling/MITgcm_fresh'


def copy_files_to_fresh_clone(mitgcm_path,create_compile_scripts):
    pwd = os.getcwd()
    pwd_short = pwd.split(os.path.sep)[-1]
    if pwd_short!='utils':
        raise ValueError('Run this code from within the utils dir')

    # step 1: remove the old boot sequence files and add the new ones
    # update_boot_sequence_files(mitgcm_path)

    # step 2: add the new diagnostics_vec_package
    # add_diagnostics_vec_package_files(mitgcm_path)

    # step 3: add the verification experiments
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

