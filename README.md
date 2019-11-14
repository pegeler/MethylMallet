MethylMallet <img src='assets/mm_logo.png' align='right' height='120px' />
==========================================================================

Full outer join of very large files using low resources.

## Table of Contents

* [System Requirements](#system-requirements)
* [Setup](#setup)
* [Usage](#usage)
* [Quality Control](#quality-control)
* [Test Data](#test-data)
* [Citation](#citation)

## System Requirements

- Required
  - bash, GNU core utils, gzip, _&c._
  - One of the following:
    - gcc
    - python3
- Optional
  - xz (compressing output file)
  - make
  - md5sum
  - R with the follwoing packages
    - doParallel
    - R.utils
    - dplyr
    - readr

This program has been implemented in Python 3 and C. You may choose
either one or the other based on resources available to you. The Python
version takes about 9x more time per file. But Python 3 will
not require extra tooling associated with building the executable from
source code.

## Setup

By default, the program will use a binary executable to do the join
operation, if it is available. Otherwise, it will fall back to the
Python 3 script. To create the binary executable, run `make` in the root
project directory.

## Usage

```
usage: ./full_join.sh [-h] [-p] [-d DIR] [-S BUFFER_SIZE] [-o OUT_FILE]
                      FILE [FILE ...]

Do a full outer join of tab-separated methylation files.

positional arguments:
  FILE            file(s) to be joined. These must be gz compressed.

required arguments:
  -d DIR          working directory (will be created if doesn't exist)
  -o OUT_FILE     file name to be output to

optional arguments:
  -h              show this help message and exit
  -p              do sorting operations using GNU parallel
  -S BUFFER_SIZE  buffer size allocated to sorting operation
```

_NOTE: The working directory should be empty._

## Quality Control

The full dataset is too big to be produced in R. However, small subsets of the data
can be managed. Therefore, we can use random selection to verify results. This
is somewhat imperfect, since we rely on the output file as the stock of keys
from which we sample.

A random sample of lines from the outfile (1000 by default) can be read in and
then a dataset matching those lines can be reproduced by reading in the source
data. Use *prod_check.r* in the *test/* folder to do this QC check.

## Test Data

<https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE43857>

## Citation

If you use this work to generate data for publication, please cite it.
A possible citation is as follows.

> Egeler, PW (2019). MethylMallet. Github Repository: <https://github.com/pegeler/MethylMallet>. Commit _put hash here_.

