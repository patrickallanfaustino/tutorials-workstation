#!/bin/bash
#SBATCH -t 24:00:00
#SBATCH --gres=gpu:2
#SBATCH --mem=16G
#SBATCH --job-name=c12_1
#SBATCH --cpus-per-task=32
#SBATCH --mail-user=patrick.faustino@unesp.br
#SBATCH --mail-type=BEGIN,END,FAIL

export INPUT="*"
export OUTPUT="*"
export VERBOSE="1"

module load gcc/14.3.0
module load cuda/12.9

# Executa o script de verificação dentro do container
job-nanny apptainer exec --nv ubuntu2404.sif bash md1.sh
