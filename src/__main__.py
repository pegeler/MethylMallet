#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Low resource full outer join"""
import sys
import os.path
import tempfile

from .mfile import Mfile
from .utils import chunk_files, gather_columns

# GLOBALS
WORK_DIR = os.path.dirname(sys.argv[1])
INFILES = sys.argv[1:]
N_FILES = len(INFILES)
CHUNK_SIZE = 100
TMPDIR = tempfile.TemporaryDirectory(dir=WORK_DIR)
TMPFILES = []
KEYS = []
HEADER = ''

if N_FILES < 2: raise Exception("Too few args")

# Put all the keys in memory
with open(os.path.join(WORK_DIR, 'keys.csv'), 'r') as fkey:
    HEADER += fkey.readline().strip()
    for key in fkey:
        KEYS.append(key.strip())

# Iterate through the files in chunks and write to temp files
for infile_chunk in chunk_files(INFILES, CHUNK_SIZE):
    files = [Mfile(f) for f in infile_chunk]
    HEADER += ',' + ','.join([f.tag for f in files])
    TMPFILES.append(tempfile.TemporaryFile(mode='w+', dir=TMPDIR.name))
    gather_columns(KEYS, files, TMPFILES[-1])
    del files[:]

# Write final output file
fout = open(os.path.join(WORK_DIR, 'out.csv'), 'w')

fout.write(HEADER + '\n')
for key in KEYS:
    data_line = [tmp.readline().strip() for tmp in TMPFILES]
    fout.write(key + ',' + ','.join(data_line) + '\n')

fout.close()
