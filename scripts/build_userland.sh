#!/bin/bash
set -e

cd userland
gcc -c libfakegpu.c -o libfakegpu.o
gcc testsubmit.c libfakegpu.o -o testsubmit
echo "Userland built"
