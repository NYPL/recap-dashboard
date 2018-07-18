#!/usr/bin/env python -tt

import sys
import glob
import re


ALLFILES = glob.glob("../harvard-data/*/*.xml")

NUMOFFILES = len(ALLFILES)


with open("../computed-data/lc-call-numbers/harvard-lc-calls.txt", "w") as fh:
    sys.stdout.write("BIBID\tBARCODE\tSTATUS\tLCCALL\tTAGANDINDICATOR\tBIBTEXT\n")
    for index, afile in enumerate(ALLFILES):
        sys.stderr.write("ON {} of {}\n".format(index+1, NUMOFFILES))
        sys.stderr.flush()

        with open(afile, "r") as current:
            line = current.readline()
            startofrow = False
            while line:
                line = line.strip()
                if line == "<row>":
                    startofrow = True
                elif re.search("^<value", line) and not re.search("xs:nil", line):
                    if not startofrow:
                        sys.stdout.write("\t")
                    startofrow = False
                    sys.stdout.write(re.sub("</value>", "", re.sub("<value>", "", line)))
                elif line == "</row>":
                    sys.stdout.write("\n")
                else:
                    startofrow = False
                line = current.readline()
