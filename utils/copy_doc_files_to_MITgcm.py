
import os
import shutil
import argparse

######################################################################
# This function is to add the documentation files to the pkg dir

def read_rst_files(mitgcm_path):

    # read existing utilities
    utilities_file = os.path.join(mitgcm_path, 'doc', 'utilities', 'utilities.rst')
    f = open(utilities_file)
    utilities_lines = f.read()
    f.close()
    utilities_lines = utilities_lines.split('\n')

    # read existing packages_II
    outp_pkgs_file = os.path.join(mitgcm_path, 'doc', 'outp_pkgs', 'outp_pkgs.rst')
    f = open(outp_pkgs_file)
    outp_pkgs_lines = f.read()
    f.close()
    outp_pkgs_lines = outp_pkgs_lines.split('\n')

    # read new diagnostics_vec lines
    diag_vec_file = os.path.join('..', 'doc', 'diagnostic_vec_doc.rst')
    f = open(diag_vec_file)
    diag_vec_lines = f.read()
    f.close()
    diag_vec_lines = diag_vec_lines.split('\n')

    return(utilities_lines,outp_pkgs_lines,diag_vec_lines)


def reorder_pkgs_and_utilities(utilities_lines,outp_pkgs_lines,diag_vec_lines):

    # step 1: move the utilities in pkgs to the end of the utilities files
    start_line = 'Grid Generation'
    end_line = '.. _sub_outp_pkg_flt:'
    for ll in range(len(outp_pkgs_lines)):
        line=outp_pkgs_lines[ll]
        if line[:len(start_line)]==start_line:
            start_line_index = ll
        if line[:len(end_line)]==end_line:
            end_line_index = ll
    utilities_lines = utilities_lines + outp_pkgs_lines[start_line_index:end_line_index]
    outp_pkgs_lines = outp_pkgs_lines[:start_line_index] + outp_pkgs_lines[end_line_index:]

    # step 2: add diagnostics_vec to the output packages file
    indicator_line = '.. _pkg_mdsio:'
    for ll in range(len(outp_pkgs_lines)):
        line=outp_pkgs_lines[ll]
        if line[:len(indicator_line)]==indicator_line:
            indicator_line_index = ll

    outp_pkgs_lines = outp_pkgs_lines[:indicator_line_index] + ['.. _pkg_diagnostics_vec:\n'] + \
                      diag_vec_lines+ ['\n\n'] + outp_pkgs_lines[indicator_line_index:]

    return(utilities_lines,outp_pkgs_lines)



def add_documentation_files(mitgcm_path,utilities_lines,outp_pkgs_lines):

    output_dir = mitgcm_path

    utilities_file = os.path.join(output_dir, 'doc', 'utilities', 'utilities.rst')
    f = open(utilities_file,'w')
    f.write('\n'.join(utilities_lines))
    f.close()

    outp_pkgs_file = os.path.join(output_dir, 'doc', 'outp_pkgs', 'outp_pkgs.rst')
    f = open(outp_pkgs_file,'w')
    f.write('\n'.join(outp_pkgs_lines))
    f.close()


def copy_files_to_fresh_clone(mitgcm_path):
    pwd = os.getcwd()
    pwd_short = pwd.split(os.path.sep)[-1]
    if pwd_short!='utils':
        raise ValueError('Run this code from within the utils dir')

    utilities_lines,outp_pkgs_lines,diag_vec_lines = read_rst_files(mitgcm_path)

    print('Moving utlities from packages II to utilities, adding diagnostics_vec to packages II')
    utilities_lines,outp_pkgs_lines = reorder_pkgs_and_utilities(utilities_lines,outp_pkgs_lines,diag_vec_lines)

    print('Updating documentation files in the doc directory')
    # step 1: add the new documentation for the diagnostics_vec_package
    add_documentation_files(mitgcm_path,utilities_lines,outp_pkgs_lines)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument("-m", "--mitgcm_directory", action="store",
                        help="Path to the MITgcm directory.", dest="mitgcm_path",
                        type=str, required=True)

    args = parser.parse_args()
    mitgcm_path = args.mitgcm_path

    copy_files_to_fresh_clone(mitgcm_path)

