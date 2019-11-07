MethylMallet <img src='assets/mm_logo.png' alt='logo' style='float: right; height: 96px;' />
===========================================

Full outer join of very large files using low resources.

## Usage

```
usage: ./full_join.sh [-h] [-p] [-d DIR] [-S BUFFER_SIZE] [-o OUT_FILE]
                      FILE [FILE ...]

Do a full outer join of tab-separated methylation files.

positional arguments:
  FILE            file(s) to be joined

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

