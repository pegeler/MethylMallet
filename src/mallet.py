# -*- coding: utf-8 -*-
import os
from multiprocessing import Pool
from resource import getrlimit, RLIMIT_NOFILE
from tempfile import TemporaryFile, TemporaryDirectory

from .mfile import Mfile


class Mallet:

    def __init__(self, infiles, chunk_size=None, n_cores=None):
        # User inputs
        if len(infiles) < 2:
            raise Exception("Too few files")
        self.infiles = infiles
        self.chunk_size = chunk_size or 100
        self.n_cores = n_cores or os.cpu_count() - 1

        # Chunks
        if len(self.infiles) % self.chunk_size == 1:
            self.chunk_size -= 1
        self.n_chunks = 1 + len(self.infiles) // self.chunk_size

        # File limit
        concurrent_files = self.n_cores * self.chunk_size + self.n_chunks
        if concurrent_files > getrlimit(RLIMIT_NOFILE)[0]:
            message = "Too many files to open at once.\n"
            message += "Reduce n_cores or chunk_size"
            raise Exception(message)

        # Files and directories
        self.work_dir = os.path.dirname(self.infiles[0])
        self.tmp_dir = TemporaryDirectory(dir=self.work_dir)

        # Key file
        with open(os.path.join(self.work_dir, 'keys.csv'), 'r') as fkey:
            self.header = fkey.readline().strip()
            self.keys = [key.strip() for key in fkey]

    # SUPPORTING UTILS ------------------------------------------------------
    def _chunk_files(self):
        # Credit: https://stackoverflow.com/a/312464
        for i in range(0, len(self.infiles), self.chunk_size):
            yield self.infiles[i:i + self.chunk_size]

    def _gather_columns(self, files, tmp_file):
        for key in self.keys:
            key_split = key.split(',')
            data_line = []
            for f in files:
                if key_split == f.data[:4]:
                    data_line.append(f.data[-1])
                    f.get_next_line()
                else:
                    data_line.append('')
            tmp_file.write(','.join(data_line) + '\n')
        tmp_file.seek(0)

    # WORKHORSE FUNCTIONS ---------------------------------------------------
    def _iterate_over_files(self, infile_chunk):
        tmp_file = TemporaryFile(mode='w+', dir=self.tmp_dir.name)
        files = [Mfile(f) for f in infile_chunk]
        self._gather_columns(files, tmp_file)
        del files[:]

        return tmp_file

    def _write_final_output(self):
        with open(os.path.join(self.work_dir, 'out.csv'), 'w') as fout:

            # Header
            tag_line = [tmp.readline().strip() for tmp in self.tmp_files]
            fout.write(self.header + ',' + ','.join(tag_line) + '\n')
            del tag_line

            # Values
            for key in self.keys:
                data_line = [tmp.readline().strip() for tmp in self.tmp_files]
                fout.write(key + ',' + ','.join(data_line) + '\n')

    # USER-FACING -----------------------------------------------------------
    def join(self):
        with Pool(self.n_cores) as p:
            self.tmp_files = p.map(
                    self._iterate_over_files,
                    self._chunk_files())
        self._write_final_output()
