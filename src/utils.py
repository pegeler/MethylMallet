def chunk_files(files, n):
    # Credit: https://stackoverflow.com/a/312464
    for i in range(0, len(files), n):
        yield files[i:i + n]


def gather_columns(keys, files, temp_file):

    # Loop over KEYS
    for key in keys:
        key_split = key.split(',')

        data_line = []

        for f in files:
            if key_split == f.data[:4]:
                data_line.append(f.data[-1])
                f.get_next_line()
            else:
                data_line.append('')

        temp_file.write(','.join(data_line))
        temp_file.write('\n')

    temp_file.seek(0)
