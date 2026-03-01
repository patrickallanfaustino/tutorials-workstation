#!/bin/bash
#SBATCH -t 00:05:00
#SBATCH --gres=gpu:1
#SBATCH --mem=16G
#SBATCH --job-name=test_gmx
#SBATCH --cpus-per-task=16
#SBATCH --mail-user=patrick.faustino@unesp.br
#SBATCH --mail-type=BEGIN,END,FAIL

export INPUT="*"
export OUTPUT="*"
export VERBOSE="1"

module load gcc/14.3.0
module load cuda/12.9

# Executa o script de verificação dentro do container
job-nanny apptainer exec --nv ubuntu2404.sif bash check.sh
