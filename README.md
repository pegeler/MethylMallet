MethylMallet <img src='assets/mm_logo.png' align='right' height='120px' />
==========================================================================

Full outer join of very large files using low resources.

## Table of Contents

* [System Requirements](#system-requirements)
* [Usage](#usage)
* [Quality Control](#quality-control)
* [Test Data](#test-data)
* [Citation](#citation)

## System Requirements

- Required
  - bash
  - GNU core utils
  - gzip
  - awk
  - python3
- Optional
  - GNU parallel
- Testing and Quality Control
  - R with the follwoing packages
    - doParallel
    - dplyr
    - readr

## Usage

```
usage:
full_join.sh [-h] [-k] -n NMERGE -S BUFFER_SIZE -d DIR -o OUT_FILE FILE [FILE ...]

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

