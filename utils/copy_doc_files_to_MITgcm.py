
import os
import shutil
import argparse

######################################################################
# This function is to add the documentation files to the pkg dir

def add_documentation_files(mitgcm_path):

    for subdir in ['outp_pkgs','utilities']:
        for file_name in os.listdir(os.path.join('..','doc',subdir)):
            if file_name[-4:]=='.rst':
                shutil.copyfile(os.path.join('..', 'doc', subdir, file_name),
                           os.path.join(mitgcm_path, 'doc', subdir, file_name))



def copy_files_to_fresh_clone(mitgcm_path):
    pwd = os.getcwd()
    pwd_short = pwd.split(os.path.sep)[-1]
    if pwd_short!='utils':
        raise ValueError('Run this code from within the utils dir')

    print('Updating documentation files in the doc directory')
    # step 1: add the new documentation for the diagnostics_vec_package
    add_documentation_files(mitgcm_path)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument("-m", "--mitgcm_directory", action="store",
                        help="Path to the MITgcm directory.", dest="mitgcm_path",
                        type=str, required=True)

    args = parser.parse_args()
    mitgcm_path = args.mitgcm_path

    copy_files_to_fresh_clone(mitgcm_path)

