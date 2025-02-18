#!/usr/bin/env python3

import glob
import math
import itertools as it
import argparse

try:
    import tqdm

    ENABLE_PROGRESSBAR = True
except ImportError:
    ENABLE_PROGRESSBAR = False


# ./concat-text.py -f "LJU*.txt" -p "../books_legal_concat/LJU" -s 500

"""
$ find . -name "MPA0000*" | wc -m
    1296

$ find . -name "MPA0000[0-4]*" | wc -m
    768

$ find . -name "MPA0000[5-9]*" | wc -m
    640

$ find . -name "0*" | xargs cat | xargs echo -n >> merged.txt

$ cat $(find . -name "0*"); echo >> merged.txt

$ find . -name "0*" | xargs sed -n p > merged.txt
"""


# text_files = glob.glob("./[0-1]*.txt")


def concat_text_by_pattern(
    src_pattern: str, target_prefix: str = "concat", concat_size: int = 500
):

    text_files = list(sorted(glob.glob(f"{src_pattern}")))
    print(len(text_files))
    text_file_groups = iter(lambda: tuple(it.islice(iter(text_files), concat_size)), ())

    target_file_num = math.ceil(len(text_files) / concat_size)
    target_file_digits = len(str(target_file_num))

    print(f"{target_file_num} Files to create...")

    if ENABLE_PROGRESSBAR:
        progress = tqdm.trange(target_file_num)
    else:
        progress = range(target_file_num)

    for p, (i, text_file_group) in zip(progress, enumerate(text_file_groups)):
        target_filename = f"{target_prefix}{i+1:0>{target_file_digits}d}.txt"
        with open(target_filename, "a+") as target_f:
            for text_file in text_file_group:
                with open(text_file, "r") as source_f:
                    src_text = source_f.read()
                target_f.write(src_text)
                target_f.write("\n")
        if not ENABLE_PROGRESSBAR:
            print(f"[{i+1}/{target_file_num}] {target_filename}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--srcfile",
        "-f",
        metavar="srcfile",
        type=str,
        default="./*",
        help='specify source filename pattern(supports regex) (default: "./")',
    )
    parser.add_argument(
        "--prefix",
        "-p",
        metavar="prefix",
        type=str,
        default="concat",
        help='specify target filename prefix (default: "concat")',
    )
    parser.add_argument(
        "--concat-size",
        "-s",
        metavar="concat_size",
        type=int,
        default=100,
        help="specify the number to concat (default: 100)",
    )
    args, _ = parser.parse_known_args()

    srcfile_pattern = args.srcfile
    target_prefix = args.prefix
    concat_size = args.concat_size
    concat_text_by_pattern(
        srcfile_pattern, target_prefix=target_prefix, concat_size=concat_size
    )
