#!/bin/bash


./do-harvard.py | perl -pe 's/^(.+?)\t.+?\t.+?\t\s*(.+?)\t.*/$1\t$2/' | awk '!x[$1]++' > "../computed-data/lc-call-numbers/harvard-lc-calls.txt"
