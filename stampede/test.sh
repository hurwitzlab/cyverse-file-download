#!/bin/bash

#SBATCH -A iPlant-Collabs
#SBATCH -p development
#SBATCH -t 02:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -J upldtst
#SBATCH --mail-type BEGIN,END,FAIL
#SBATCH --mail-user kyclark@email.arizona.edu

set -u

./run.sh -f files.txt -d upload_test
