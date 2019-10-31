#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Low resource full outer join
"""
import sys
import re
import shutil
import shlex
import subprocess
import os.path
import tempfile


class Join:
    def __init__(self,
                 in_files,
                 out_file,
                 working_dir=None,
                 buffer_size=None) -> None:
        self.in_files = _get_tags(in_files)
        self.out_file = open(out_file, 'w+')
        self.working_dir = tempfile.TemporaryDirectory(dir=working_dir)
        self.buffer_size = '-S ' + buffer_size if buffer_size else ''

    def _get_tags(files) -> dict:
        return {re.search(r'^(.*?)_', os.path.basename(x))[1]: x
                for x in files}

    def _sort_inputs(self) -> None:
        """Sort the files and put them in a temporary directory"""

        command =  'tail -q -n +2 "{}" | '
        command += 'sort -k 1n,1 -k 2n,2 -k 3,3 -k 4,4 {} -T {} -o "{}"'

        sorted_files = {}

        for k in self.infiles:
            # File path
            file_path = self.infiles.get(k)

            # Destination file
            dest = os.path.join(
                    self.working_dir.name,
                    "sorted_" + os.path.basename(file_path))
            subprocess.run(
                    command.format(file_path,
                                   self.buffer_size,
                                   self.working_dir.name,
                                   dest),
                    check=True,
                    shell=True)
            sorted_files.update({k: dest})

        self.sorted_files = sorted_files

    def _generate_keys(self):
        """Generate the keys"""

        sorted_files = [str(v) for k, v in self.sorted_files.items()]

        self.out_file.write('chrom,pos,strand,mc_class\n')

        command = 'sort -k 1n,1 -k 2n,2 -k 3,3 -k 4,4 -u -m {} -T {} {} |'
        command += 'cut -f 1,2,3,4 |'
        command += r"tr '\t' ,"
        subprocess.run(
                command.format(self.buffer_size,
                               self.working_dir.name,
                               " ".join(sorted_files)),
                stdout=self.out_file,
                check=True,
                shell=True)


    def _append(self):
        pass

    def full_outer_join():
        work = open('working/out.csv', 'r')

        # Header ---
        header = work.readline().strip()
        header += ',' + #tag# + '\n'
        temp.write(header)

        del header

        # Preload first line from stdin
        candidate = sys.stdin.readline().strip().split()

        # Loop over working file
        for line in work:
            line = line.strip()
            if line.split(',', 4)[:4] == candidate[:4]:
                # Write line!
                temp.write(line + ',' + candidate[-1] + '\n')
                # Load in next line
                candidate = sys.stdin.readline().strip().split()
            else:
                temp.write(line + ',\n')

        # Close file connections
        temp.close()
        work.close()

# At last, copy tmp into out
shutil.move('working/tmp.csv', 'working/out.csv')
