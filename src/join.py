#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Low resource full outer join
"""
import sys
import re
import shutil
import subprocess
import os.path
import tempfile


class Join:
    def __init__(self, infiles, outfile=None, working_dir=None) -> None:
        self.infiles = _get_tags(infiles)
        self.outfile = outfile
        self.working_dir = (working_dir or tempfile.TemporaryDirectory())
        self.temp = tempfile.TemporaryFile('w+')

    def _get_tags(files) -> dict:
        return {re.search(r'^(.*?)_', os.path.basename(x))[1]: x
                for x in files}

    def _sort_inputs(self) -> dict:
        """Sort the files and put them in a temporary directory"""

        command =  'tail -q -n +2 "{}" | '
        command += 'sort -k 1n,1 -k 2n,2 -k 3,3 -k 4,4 -S 2G -o "{}"'
        sorted_files = {}

        for k in self.infiles:
            file_path = self.infiles.get(k)
            dest = os.path.join(
                    self.working_dir.name,
                    "sorted_" + os.path.basename(file_path))
            subprocess.run(command.format(file_path, dest), shell=True)
            sorted_files.update({k: dest})

        return sorted_files

    def _generate_keys(self):
        pass

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
