# -*- coding: utf-8 -*-
import os
from tempfile import TemporaryFile, TemporaryDirectory

from .mfile import Mfile


class Mallet:

    def __init__(self, infiles, chunk_size=100):
        if len(infiles) < 2:
            raise Exception("Too few files")

        self.infiles = infiles
        self.chunk_size = chunk_size
        self.work_dir = os.path.dirname(self.infiles[0])
        self.tmp_dir = TemporaryDirectory(dir=self.work_dir)
        self.tmp_files = []

        with open(os.path.join(self.work_dir, 'keys.csv'), 'r') as fkey:
            self.header = fkey.readline().strip()
            self.keys = [key.strip() for key in fkey]

    # SUPPORTING UTILS ------------------------------------------------------
    def _chunk_files(self, files):
        # Credit: https://stackoverflow.com/a/312464
        for i in range(0, len(files), self.chunk_size):
            yield files[i:i + self.chunk_size]

    def _gather_columns(self, files):
        # Header
        self.tmp_files[-1].write(','.join([f.tag for f in files]) + '\n')

        # Values
        for key in self.keys:
            key_split = key.split(',')
            data_line = []
            for f in files:
                if key_split == f.data[:4]:
                    data_line.append(f.data[-1])
                    f.get_next_line()
                else:
                    data_line.append('')
            self.tmp_files[-1].write(','.join(data_line) + '\n')

        # Seek back to the top
        self.tmp_files[-1].seek(0)

    # WORKHORSE FUNCTIONS ---------------------------------------------------
    def _iterate_over_files(self):
        for infile_chunk in self._chunk_files(self.infiles):
            files = [Mfile(f) for f in infile_chunk]
            self.tmp_files.append(TemporaryFile(mode='w+',
                                                dir=self.tmp_dir.name))
            self._gather_columns(files)
            del files[:]

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
        self._iterate_over_files()
        self._write_final_output()
