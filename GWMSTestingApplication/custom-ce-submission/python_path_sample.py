#!/usr/bin/env python3

import os
import argparse

parser = argparse.ArgumentParser(description="Python Path Sample")
parser.add_argument('file')
args = parser.parse_args()

WORK_DIR = os.getcwd()
print(f"User working directory: {WORK_DIR}")

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
print(f"Script root directory: {ROOT_DIR}")

f = open(ROOT_DIR + "/job.env")
print(f)

if not os.path.isabs(args.file):
    args.file = WORK_DIR + "/" + args.file
f = open(args.file)
print(f)