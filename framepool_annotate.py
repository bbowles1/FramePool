#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Feb  8 07:26:34 2023

Script to invoke FramePool annotation provided an input dataframe path

@author: bbowles
"""

import sys
sys.path.append('/app/modules/')
from kipoi_functions import framepool_caller

def main():
    # Create an argument parser
    parser = argparse.ArgumentParser(description="Annotate an ORFA file with FramePool ribosome load prediction.")

    # Add the "--input" argument
    parser.add_argument("--input", help="Input, tab-delimited ORFA file.", required=True)

    # Parse the command line arguments
    args = parser.parse_args()

    # Get and print the full path
    path = args.input

    if path.endswith(".tsv"):

        # run FramePool
        scored_df = framepool_caller(path)

        # save output
        outpath = path.replace(".tsv",".framepool.tsv")
        scored_df.to_csv(outpath, index=False, sep='\t')
        print(f"Saved FramePool-annotated output to {outpath}.")

    else:
        raise Exception("Input file must end with .tsv!")

if __name__ == "__main__":
    main()