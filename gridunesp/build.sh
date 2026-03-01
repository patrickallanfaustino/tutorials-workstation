#!/bin/bash
#SBATCH -t 24:00:00
#SBATCH --job-name=apptainer
#SBATCH --cpus-per-task=16
#SBATCH --mail-user=patrick.faustino@unesp.br
#SBATCH --mail-type=BEGIN,END,FAIL

export INPUT="gromacs-gpu.def"
export OUTPUT="*"
export VERBOSE="1"

job-nanny apptainer build ubuntu2404.sif gromacs-gpu.def
