#!/bin/bash

uniq < "../computed-data/lc-call-numbers/harvard-lc-calls.txt" | sponge "../computed-data/lc-call-numbers/harvard-lc-calls.txt" 
