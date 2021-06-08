
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

    pkg_already_added = False
    for line in lines:
        if 'useDiagnostics_vec' in line:
            pkg_already_added = True

    if not pkg_already_added:
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
    return(pkg_already_added)

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

    pkg_already_added = update_PARAMS(inc_dir)
    if not pkg_already_added:
        update_packages_boot(src_dir)
        update_packages_check(src_dir)
        update_packages_init_fixed(src_dir)
        update_packages_init_variables(src_dir)
        update_packages_readparms(src_dir)
        update_do_the_model_io(src_dir)
    else:
        print('    Diagnostics_vec has already been added to the boot sequence!')

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

######################################################################
# This function is the main utility

def copy_files_to_fresh_clone(mitgcm_path):
    pwd = os.getcwd()
    pwd_short = pwd.split(os.path.sep)[-1]
    if pwd_short!='utils':
        raise ValueError('Run this code from within the utils dir')

    print('Updating the boot sequence files in model/* directory')
    # step 1: edit the old boot sequence files to add the new package
    update_boot_sequence_files(mitgcm_path)

    print('Updating diagnostics_vec files in the pkg directory')
    # step 2: add the new diagnostics_vec_package
    add_diagnostics_vec_package_files(mitgcm_path)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument("-m", "--mitgcm_directory", action="store",
                        help="Path to the MITgcm directory.", dest="mitgcm_path",
                        type=str, required=True)

    args = parser.parse_args()
    mitgcm_path = args.mitgcm_path

    copy_files_to_fresh_clone(mitgcm_path)

