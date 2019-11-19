#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from distutils.core import setup
import sys

# Currently, only supported through shell script
sys.stderr.write("WARNING: Package will not be installed!\n")
sys.stderr.write("Current support only for internal use by shell scripts.\n")
sys.exit(1)

if sys.version_info.major < 3:
    sys.stderr.write("Error: This package requires python3\n")
    sys.exit(1)

setup(name="MethylMallet",
      version="0.0",
      author="Paul W. Egeler, M.S., GStat",
      author_email="paul.egeler@spectrumhealth.org",
      description="Prepare MethylC-seq data for analysis",
      url="https://github.com/SpectrumHealthResearch/MethylMallet/",
      license="GPL-3",
      package_dir={"MethylMallet": "src"},
      packages=["MethylMallet"],
      keywords=["methylation", "MethylC-seq", "bioinformatics"])
