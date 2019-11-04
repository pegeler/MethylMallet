methyl
======

Full outer join of very large files using low resources.

## Usage

```
usage: ./full_join.sh [-h] [-p] [-d DIR] [-S BUFFER_SIZE] [-o OUT_FILE]
                      FILE [FILE ...]

Do a full outer join of tab-separated methylation files.

positional arguments:
  FILE            file(s) to be joined

required arguments:
  -d DIR          working directory
  -o OUT_FILE     file name to be output to

optional arguments:
  -h              show this help message and exit
  -p              do sorting operations using GNU parallel
  -S BUFFER_SIZE  buffer size allocated to sorting operation
```
