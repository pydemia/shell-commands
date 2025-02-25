#!/usr/bin/env python3

import glob
import math
from pathlib import Path
import itertools as it
import argparse

try:
    import tqdm

    ENABLE_PROGRESSBAR = True
except ImportError:
    ENABLE_PROGRESSBAR = False

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


# ./concat-text.py -d books_medical -f "MPA*.txt" -t books_medical_concat -p "MPA" -s 300
# ./concat-text.py -d books_medical -f "MTB*.txt" -t books_medical_concat -p "MTB" -s 300
# ./concat-text.py -d books_legal -f "LJU*.txt" -t books_legal_concat -p "LJU" -s 200
# ./concat-text.py -d books_legal -f "LTB*.txt" -t books_legal_concat -p "LTB" -s 300

# text_files = glob.glob("./[0-1]*.txt")


def concat_text_by_pattern(
    source_dir: str = "",
    source_pattern: str = "*",
    target_dir: str = "concat",
    target_prefix: str = "concat",
    concat_size: int = 500,
):

    def even_chunk(iterable, chunk_size):
        iterator = iter(iterable)
        slicer = iter(lambda: list(it.islice(iterator, chunk_size)), [])
        yield from slicer

    text_files = list(sorted(Path(source_dir).glob(f"{source_pattern}")))
    text_file_groups = even_chunk(text_files, concat_size)

    target_file_num = math.ceil(len(text_files) / concat_size)
    target_file_digits = len(str(target_file_num))

    print(f"{target_file_num} Files to create...")

    if ENABLE_PROGRESSBAR:
        progress = tqdm.trange(target_file_num)
    else:
        progress = range(target_file_num)

    Path(target_dir).mkdir(parents=True, exist_ok=True)
    for p, (i, text_file_group) in zip(progress, enumerate(text_file_groups)):
        target_filename = f"{target_prefix}{i+1:0>{target_file_digits}d}.txt"
        target_file = Path(target_dir).joinpath(target_filename)
        with open(target_file, "a+") as target_f:
            for text_file in text_file_group:
                with open(text_file, "r") as source_f:
                    src_text = source_f.read()
                target_f.write(src_text)
                target_f.write("\n")

        with open(target_file, "a+") as target_f:
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
        "--src-dir",
        "-d",
        metavar="src_dir",
        type=str,
        default="./*",
        help='specify source dir (default: "./")',
    )
    parser.add_argument(
        "--src-pattern",
        "-f",
        metavar="src_pattern",
        type=str,
        default="*",
        help='specify source filename pattern(supports regex) (default: "*")',
    )
    parser.add_argument(
        "--target-dir",
        "-t",
        metavar="target_dir",
        type=str,
        default="concat",
        help='specify target filename prefix (default: "concat")',
    )
    parser.add_argument(
        "--target-prefix",
        "-p",
        metavar="target_prefix",
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

    source_dir = args.src_dir
    source_pattern = args.src_pattern
    target_dir = args.target_dir
    target_prefix = args.target_prefix
    concat_size = args.concat_size

    concat_text_by_pattern(
        source_dir=source_dir,
        source_pattern=source_pattern,
        target_dir=target_dir,
        target_prefix=target_prefix,
        concat_size=concat_size,
    )
