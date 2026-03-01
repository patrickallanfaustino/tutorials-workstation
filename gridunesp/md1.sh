#!/bin/bash

    # Verifica a versão do Gromacs
    gmx --version
    
    # Diretório de trabalho
    cd rep1
    
    # Gerar arquivo .tpr
    gmx grompp -v -f inputs/md.mdp -c npt.gro -t npt.cpt -o md_500ns.tpr -p topol.top
    
    # Dinâmica de produção
    gmx mdrun -v -deffnm md_500ns -nb gpu -bonded gpu -update gpu -pin on -nt 16 -ntmpi 1

    # Continuação da dinâmica de produção
    # gmx mdrun -v -deffnm md_500ns -cpi md_500ns.cpt -nb gpu -bonded gpu -update gpu -pin on -nt 16 -ntmpi 1
