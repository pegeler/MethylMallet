#!/usr/bin/env python3
from bitarray import bitarray
from os.path import basename
import re
import gzip


class Mallet():

    def __init__(self, files):
        self.files = files
        self.n_columns = len(files)
        self.keys = self._get_keys()
        self.data = len(self.keys) * self.n_columns * 2 * bitarray('0')
        self.current_column = 0
        self._read_data()
        r = re.compile(r'^(GSM[0-9]+)')
        self.tags = [r.match(basename(f)).group(1) for f in files]

    def _parse_line(self, string, n_fields=4, sep='\t'):
        n_sep = 0
        for i in range(len(string)):
            if string[i] == sep:
                n_sep += 1
            if n_sep == n_fields:
                return string[:i], string[-1]
        raise Exception

    def _update(self, line):
        key, value = self._parse_line(line.strip())
        row = self.keys.get(key)
        location = row * self.n_columns*2 + self.current_column*2
        length = 2 if value == '1' else 1
        self.data[location:(location + length)] = True

    def _get_keys(self):
        key_set = set()
        for f in self.files:
            lines = gzip.open(f, 'rt').readlines()
            first_line = 1 if lines[0][:5] == 'chrom' else 0
            key_set |= {self._parse_line(i)[0] for i in lines[first_line:]}
        return {k: v for v, k in enumerate(key_set)}

    def _read_data(self):
        for f in self.files:
            fin = gzip.open(f, 'rt')
            first_line = fin.readline()
            if first_line[:5] != 'chrom':
                self._update(first_line)
            for line in fin:
                self._update(line)
            self.current_column += 1

    def write_file(self, path):
        sep = '\t'  # Only supporting tabs for now
        d = {'': bitarray('00'), '0': bitarray('10'), '1': bitarray('11')}
        
        fout = gzip.open(path, 'wt')
        
        header = ['chrom', 'pos', 'strand', 'mc_class'] + self.tags
        fout.write(sep.join(header) + '\n')

        for k in self.keys:
            row = self.keys.get(k)
            start = row*self.n_columns*2
            stop = (row + 1)*self.n_columns*2
            fout.write(k + sep)
            fout.write(sep.join(self.data[start:stop].iterdecode(d)))
            fout.write('\n')


if __name__ == "__main__":
    from sys import argv

    m = Mallet(argv[2:])
    m.write_file(argv[1])
