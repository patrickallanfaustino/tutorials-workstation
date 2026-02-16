#!/bin/bash

    # Verifica a versão do Gromacs
    gmx --version
    
    # Diretório de trabalho
    cd md1
    
    # Gerar arquivo .tpr
    gmx grompp -v -f inputs/md.mdp -c npt.gro -t npt.cpt -o md_500ns.tpr -p topol.top
    
    # Dinâmica de produção
    gmx mdrun -v -deffnm md_500ns

