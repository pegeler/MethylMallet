# -*- coding: utf-8 -*-
import re
import os.path


class Mfile:

    def __init__(self, file_path):
        self.handle = open(file_path, 'r')
        basename = os.path.basename(file_path)
        self.tag = re.search(r'^sorted_(.*?)_', basename).group(1)
        self.get_next_line()

    def __del__(self):
        self.handle.close()

    def get_next_line(self):
        self.data = self.handle.readline().strip().split()
