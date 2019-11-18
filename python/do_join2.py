#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Low resource full outer join"""
import sys
import re
import os.path
from resource import getrlimit, RLIMIT_NOFILE


class Mfile:

    def __init__(self, file_path):
        self.file_path = file_path
        self.handle = open(file_path, 'r')
        self.dir_, self.file_name = os.path.split(file_path)
        self.tag = re.search(r'^sorted_(.*?)_', self.file_name).group(1)
        self.get_next_val()

    def __del__(self):
        self.handle.close()

    def get_next_val(self):
        self.data = self.handle.readline().strip().split()

#    Code below opens and seeks the file each time it needs a new line...
#    Keeping this around b/c not sure if the OS will like having 1k files open
#    sumultaneously. Will do some field tests.
#
#    def __init__(self, file_path):
#        self.pos = 0
#        self.file_path = file_path
#        self.dir_, self.file_name = os.path.split(file_path)
#        self.tag = re.search(r'^sorted_(.*?)_', self.file_name).group(1)
#        self.get_next_val()
#
#    def get_next_val(self):
#        infile = open(self.file_path, 'r')
#        infile.seek(self.pos)
#        self.data = infile.readline().strip().split()
#        self.pos = infile.tell()
#        infile.close()


if __name__ == "__main__":

    n_files = len(sys.argv[1:])

    if n_files + 2 > getrlimit(RLIMIT_NOFILE)[0]:
        raise Exception("Can't open that many files.")

    # Initialize methylation files
    files = [Mfile(f) for f in sys.argv[1:]]

    # Open key and out files
    fkey = open(os.path.join(files[0].dir_, 'keys.csv'), 'r')
    fout = open(os.path.join(files[0].dir_, 'out.csv'), 'w')

    # Write header
    header = fkey.readline().strip() + ','
    header += ','.join([f.tag for f in files]) + '\n'
    fout.write(header)

    # Loop over keys
    for key in fkey:
        key = key.strip()
        fout.write(key + ',')
        key_split = key.split(',')

        data_line = []

        for f in files:
            if key_split == f.data[:4]:
                data_line.append(f.data[-1])
                f.get_next_val()
            else:
                data_line.append('')

        fout.write(','.join(data_line))
        fout.write('\n')

    del files[:]

    # Close file connections
    fkey.close()
    fout.close()
