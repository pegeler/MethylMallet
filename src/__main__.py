#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
from .mallet import Mallet

m = Mallet(sys.argv[1:])
m.join()
