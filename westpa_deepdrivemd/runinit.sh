#!/bin/bash
#SBATCH -p development 
#SBATCH -J we-init
#SBATCH -o init.%j.%N.initout
#SBATCH -e init.%j.%N.initerr
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 00:10:00

set -x

echo "start init"
./init.sh
echo "finish init"

