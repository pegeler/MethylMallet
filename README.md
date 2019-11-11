MethylMallet <img src='assets/mm_logo.png' align='right' height='120px' />
==========================================================================

Full outer join of very large files using low resources.

## System Requirements

- Required
  - bash
  - GNU sort
  - One of the following:
    - g++ version 8 with libboost
    - python3
- Optional
  - GNU parallel

This program has been implemented in Python 3 and C++. You may choose
either one or the other based on resources available to you. The Python
version takes about 65 percent more time per file. But Python 3 will
not require extra tooling associated with building the executable from
source code.

## Setup

By default, the program will use a binary executable to do the join
operation, if it is available. Otherwise, it will fall back to the
Python 3 script. To create the binary executable, run `make` in the root
project directory.

### Tips on Ubuntu

On Ubuntu 18.04, you will likely need to install a few extra things:

```bash
sudo apt-get update
sudo apt-get install g++-8 libbost-dev
```

Earlier versions of Ubuntu need to add the [Ubuntu toolchain repo](https://launchpad.net/~ubuntu-toolchain-r/+archive/ubuntu/test). Do this before running the code above:

```bash
sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
```

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

## Test Data

<https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE43857>

