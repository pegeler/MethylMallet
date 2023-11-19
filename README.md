MethylMallet <img src='assets/mm_logo.png' align='right' height='120px' />
==========================================================================

Full outer join of very large gene methylation data files using low resources.

## Table of Contents

* [System Requirements](#system-requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Quality Control](#quality-control)
* [Test Data](#test-data)
* [Citation](#citation)

## System Requirements

- Required
  - bash
  - GNU core utils
  - gzip
  - gcc 
- Optional
  - GNU parallel
  - make
- Testing and Quality Control
  - python3
  - R with the follwoing packages
    - doParallel
    - dplyr
    - readr

## Installation

Prior to running this script, you must compile the C source code.
If you have `make` and `gcc` installed on your computer, compiling
is as easy as the following line.

```bash
make
```

### Development Environment

If you are running this script on GNU-Linux, these programs are likely already
installed. If you do not have a development environment, you will need to
install one. MacOS users can install [Xcode](https://developer.apple.com/xcode/)
while I recommend [RTools](https://cran.r-project.org/bin/windows/Rtools/) for
Windows users.

## Usage

```
usage:
methyl_mallet [-h] [-k] -n NMERGE -S BUFFER_SIZE -d DIR -o OUT_FILE FILE [FILE ...]

Do a full outer join of tab-separated methylation files.

positional arguments:
  FILE            files to be joined

required arguments:
  -d DIR          working directory (doesn't need to exist but should be empty)
  -o OUT_FILE     file name to be output to

optional arguments:
  -h              show this help message and exit
  -k              keep intermediary files
  -n NMERGE       number of files to merge simultaneously
  -S BUFFER_SIZE  buffer size allocated to sorting operation
```

_NOTE: The working directory should be empty._

## Quality Control

The full dataset is too big to be produced in R. However, small subsets of the
data can be managed. Therefore, we can use random selection to verify results.
This is somewhat imperfect, since we rely on the output file as the stock of
keys from which we sample.

A random sample of lines from the outfile (1000 by default) can be read in and
then a dataset matching those lines can be reproduced by reading in the source
data. Use *prod_check.r* in the *qc/* folder to do this QC check.

## Test Data

<https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE43857>

## Citation

If you use this work to generate data for publication, please cite it.
A possible citation is as follows.

> Egeler, PW (2019). MethylMallet. Github Repository: <https://github.com/SpectrumHealthResearch/MethylMallet>. Commit _put hash here_.

