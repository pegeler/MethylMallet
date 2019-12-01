#!/usr/bin/env python3
from bitstring import BitArray
from os.path import basename
import re
import gzip


class Mallet():

    def __init__(self, files):
        self.files = files
        self.n_columns = len(files)
        self.data = {}
        self.current_column = 0
        for file in files:
            fin = gzip.open(file, 'rt')
            first_line = fin.readline()
            if first_line[:5] != 'chrom':
                self._update(first_line)
            for line in fin:
                self._update(line)
            self.current_column += 1

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

    def _insert_value(self, bits, value):
        bits.set(True, self.current_column*2)
        if value == '1':
            bits.set(True, self.current_column*2 + 1)
        return bits

    def _update(self, line):
        key, value = self._parse_line(line.strip())
        bits = self.data.get(key, BitArray(self.n_columns * 2))
        self.data.update({key: self._insert_value(bits, value)})

    def _bits_to_char(self, bits, sep):
        out = ''
        for i in range(0, len(bits), 2):
            out += sep
            if bits[i] == '1':
                out += bits[i + 1]
        return out

    def write_file(self, path):
        sep = '\t'  # Only supporting tabs for now
        header = ['chrom', 'pos', 'strand', 'mc_class'] + self.tags

        fout = gzip.open(path, 'wt')
        fout.write(sep.join(header) + '\n')

        for k, v in self.data.items():
            fout.write(k + self._bits_to_char(v.bin, sep) + '\n')


if __name__ == "__main__":
    from sys import argv

    m = Mallet(argv[2:])
    m.write_file(argv[1])
