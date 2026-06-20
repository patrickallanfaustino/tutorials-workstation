#!/bin/bash
#SBATCH -t 00:10:00
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=24
#SBATCH --mem=16G
#SBATCH --job-name=4c_cho
#SBATCH --mail-user=patrick.faustino@unesp.br
#SBATCH --mail-type=BEGIN,END,FAIL

export INPUT="4c_cho gromacs-gpu.sif 4c_cho.sh"
export OUTPUT="*"
export VERBOSE="1"

module load gcc/14.3.0
module load cuda/12.9

# Executa o script de verificação dentro do container
job-nanny apptainer exec --nv gromacs-gpu.sif bash 4c_cho.sh
