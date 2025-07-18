import sys
import json
import os
import glob
import argparse
import platform
from pathlib import Path

def contains_sublist(lst, sublst):
    n = len(sublst)
    return any((sublst == lst[i:i+n]) for i in range(len(lst)-n+1))

def match_any(path, pattern_list):
    return any(path.match(pattern_list[i]) for i in range(len(pattern_list)))

parser = argparse.ArgumentParser(description='List installed files of given packages within current Conda environment')

parser.add_argument('filetype', choices=['all', 'headers', 'static-libs', 'shared-libs', 'exec'])
parser.add_argument('packages', help='Conda packages to list intalled files from, as a semi-colon separated list')

args = parser.parse_args()

if not os.environ["CONDA_PREFIX"]:
    print('CONDA_PREFIX environment variable not set. This script must be called from an active conda environment', file=sys.stderr)
    sys.exit(1)

conda_meta_dir = os.path.join(os.environ["CONDA_PREFIX"], "conda-meta")
if not os.path.isdir(conda_meta_dir):
    print('Conda meta directory is not a valid directory:', conda_meta_dir, file=sys.stderr)
    sys.exit(1)
    
deps_files = []
# Get conda package metadata for each listed dependency in argv
for dep in args.packages.split(';'):
    filename_pattern = dep + "*.json"
    dep_conda_meta_filenames = glob.glob(os.path.join(conda_meta_dir, filename_pattern))
    if len(dep_conda_meta_filenames) != 1:
        print('Found none or several matches for dependency ', dep, ' in conda meta dir ', conda_meta_dir, '(glob results = ', dep_conda_meta_filenames, ')', file=sys.stderr)
        sys.exit(1)
    dep_conda_meta_filename = dep_conda_meta_filenames[0]
    if not os.path.isfile(dep_conda_meta_filename):
        print('Failed to find conda meta file for dependency ',dep, ', value = ', dep_conda_meta_filename, file=sys.stderr)
        sys.exit(1)
    with open(dep_conda_meta_filename, 'r') as dep_conda_meta_file:
        conda_meta_data = json.load(dep_conda_meta_file)
        deps_files.append(conda_meta_data['files'])

system_type = platform.system()

header_suffix = Path('Library/include') if system_type == 'Windows' else Path('include')
static_lib_suffix = Path('Library/lib') if system_type == 'Windows' else Path('lib')
shared_lib_suffix = Path('Library/bin') if system_type == 'Windows' else Path('lib')
exec_suffix = Path('Library/bin') if system_type == 'Windows' else Path('bin')

static_lib_ext = ['*.lib'] if system_type == 'Windows' else ['*.a']
shared_lib_ext = ['*.dll'] if system_type == 'Windows' else ['*.so*', '*.dylib*']
exec_ext = ['*.exe'] if system_type == 'Windows' else ['*']

out_list = ""
for dep_files in deps_files:
    for file in dep_files:
        # filter files according requested file types
        filepath = Path(file)
        if args.filetype == 'all':
            out_list += file + ";"
        elif args.filetype == 'headers':
            if contains_sublist(filepath.parts, header_suffix.parts):
                out_list += file + ";"
        if args.filetype == 'static-libs':
            if contains_sublist(filepath.parts, static_lib_suffix.parts) and match_any(filepath, static_lib_ext):
                out_list += file + ";"
        if args.filetype == 'shared-libs':
            if contains_sublist(filepath.parts, shared_lib_suffix.parts) and match_any(filepath, shared_lib_ext):
                out_list += file + ";"
        if args.filetype == 'exec':
            if contains_sublist(filepath.parts, exec_suffix.parts) and match_any(filepath, exec_ext):
                out_list += file + ";"

# output result to stdout
print(out_list)

sys.exit(0)