#!/bin/bash

gmx --version

cd 4c_cho

gmx grompp -v \
    -f inputs/md.mdp \
    -c npt.gro \
    -t npt.cpt \
    -o md_200ns.tpr \
    -p topol.top

# VARIANTE A — sistemas com SPC/E, TIP3P (sem virtual site)
# Offloading máximo: NB + PME + bonded + update na GPU
#gmx mdrun -v \
#    -deffnm md_200ns \
#    -ntmpi 1 \
#    -ntomp 16 \
#    -gpu_id 0 \
#    -nb gpu \
#    -pme gpu \
#    -bonded gpu \
#    -update gpu \
#    -pin on \
#    -maxh 23.3
#
# ------------------------------------------------------------
# VARIANTE B — sistemas com TIP4P/TIP4P-Ew (virtual site)
# -para sistemas pequenos/médios de ~150k atomos
# ------------------------------------------------------------
gmx mdrun -v \
    -deffnm md_200ns \
    -ntmpi 1 \
    -ntomp 24 \
    -gpu_id 0 \
    -nb gpu \
    -pme gpu \
    -bonded gpu \
    -pin on \
    -maxh 23.3

# ------------------------------------------------------------
# VARIANTE B — sistemas com TIP4P/TIP4P-Ew (virtual site)
# -configuração para 2 GPUs (1 rank PP + 1 rank PME)
# -para sistemas pequenos/médios de ~150k atomos
# SBATCH --cpus-per-task=24
# SBATCH --gres=gpu:2
# ------------------------------------------------------------
#gmx mdrun -v \
#    -deffnm md_200ns \
#    -ntmpi 2 \
#    -ntomp 12 \
#    -npme 1 \
#    -gpu_id 01 \
#    -nb gpu \
#    -pme gpu \
#    -bonded gpu \
#    -pin on \
#    -maxh 23.3
#
