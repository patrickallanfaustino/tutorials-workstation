# Workflow para Dinâmica Molecular utilizando gridUNESP

![GitHub repo size](https://img.shields.io/github/repo-size/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub language count](https://img.shields.io/github/languages/count/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub forks](https://img.shields.io/github/forks/patrickallanfaustino/tutorials?style=for-the-badge)

<img src="picture_gridunesp2.png" alt="gridunesp">

> Tutorial para criar container com suporte ao uso de GPU CUDA no gridUNESP.

⚠️ Antes de começar, leia a documentação do [gridUNESP](https://www.ncc.unesp.br/gridunesp/docs/v2/index.html) e documentações complementares [CUDA 13](https://docs.nvidia.com/cuda/index.html) e [GROMACS 2026.x](https://manual.gromacs.org/current/index.html).

---
## 🔧 Criando o container com Apptainer

A tecnica de containeres com apptainer, docker e outros softwares busca criar imagens e ambientes de sistemas com bibliotecas instaladas o qual o processamento é feito dentro do contêiner que se comunica com o host principal. Recentemente, o gridUNESP implementou a contêinirização em seus servidores.

Para criar um container, precisamos de dois arquivos: [gromacs-gpu.def](gridunesp/gromacs-gpu.def) e [build.sh](gridunesp/build.sh).

No [gromacs-gpu.def](gridunesp/gromacs-gpu.def), será feito o download da imagem do ubuntu 24.04 com bibliotecas CUDA pré instaladas do DockerHub, será instalado bibliotecas dependências do gromacs 2026.0 incluindo o PyTorch 2.10 para CUDA, compilado o gromacs e por ultimo configurado os paths do sistema.

**[gromacs-gpu.def](gridunesp/gromacs-gpu.def):**
```
Bootstrap: docker
From: nvidia/cuda:12.9.1-devel-ubuntu24.04

%post
    # --- 1. Preparação do Sistema ---
    export DEBIAN_FRONTEND=noninteractive
    
    # Define variáveis de ambiente para a fase de compilação
    export CUDA_HOME=/usr/local/cuda
    export PATH=$CUDA_HOME/bin:$PATH
    export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
    
    apt update
    
    # Trava todos os pacotes que começam com 'cuda', 'libnvidia', ou 'libcudnn'
    apt-mark hold $(apt-cache pkgnames | grep -E "^cuda|^libnvidia|^libcudnn")
    
    apt upgrade -y
    
    # Verificação do sistema
    nvcc --version
    cat /etc/os-release
    uname -r
    g++ --version
    ldd --version

    # Instalação do repositório Kitware para o CMake atualizado
    apt install -y wget gpg
    test -f /usr/share/doc/kitware-archive-keyring/copyright || \
    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | \
    tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
    
    echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ noble main' | \
    tee /etc/apt/sources.list.d/kitware.list >/dev/null
    
    apt update
    apt install -y cmake
    cmake --version
    
    # Instalação de dependências de compilação e Python
    apt install -y \
        libboost-all-dev \
        openmpi-bin \
        openmpi-common \
        libopenmpi-dev \
        libgomp1 \
        unzip \
        gcc-14 \
        g++-14 \
        freeglut3-dev \
        curl \
        build-essential \
        libxml2-dev \
        git \
        hwloc \
        libhwloc-dev \
        libopenblas-dev \
        liblapack-dev \
        libgl1 \
        libglib2.0-0 \
        texlive \
        libhdf5-dev \
        hdf5-tools \
        libtinyxml2-dev \
        libzstd-dev \
        zlib1g-dev \
        tzdata \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev

    # Configuração do GCC
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 100 --slave /usr/bin/g++ g++ /usr/bin/g++-14
    g++ --version
    
    # Limpeza
    apt autoremove -y
    apt autoclean -y
    
    # Configuração de Timezone
    ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
    dpkg-reconfigure -f noninteractive tzdata

    # --- 2. Compilação do GROMACS 2026.0 ---
    GROMACS_VERSION=2026.0
    
    cd /opt
    wget https://download.pytorch.org/libtorch/cu128/libtorch-shared-with-deps-2.10.0%2Bcu128.zip
    unzip libtorch-shared-with-deps-2.10.0+cu128.zip
    rm libtorch-shared-with-deps-2.10.0+cu128.zip
    mv libtorch /usr/local/libtorch

    wget https://ftp.gromacs.org/gromacs/gromacs-${GROMACS_VERSION}.tar.gz
    tar xfz gromacs-${GROMACS_VERSION}.tar.gz
    cd gromacs-${GROMACS_VERSION}
    
    mkdir build
    cd build
    
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DGMX_BUILD_OWN_FFTW=ON \
        -DREGRESSIONTEST_DOWNLOAD=ON \
        -DGMX_GPU=CUDA \
        -DCUDAToolkit_ROOT=/usr/local/cuda \
        -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda \
        -DGMX_HWLOC=ON \
        -DGMX_USE_PLUMED=ON \
        -DGMX_USE_COLVARS=INTERNAL \
        -DGMX_USE_HDF5=ON \
        -DGMX_NNPOT=TORCH \
        -DGMX_EXTERNAL_TINYXML2=ON \
        -DGMX_EXTERNAL_ZLIB=ON \
        -DCMAKE_PREFIX_PATH="/usr/local/libtorch;/usr/local/cuda" \
        -DCMAKE_INSTALL_PREFIX=/usr/local/gromacs

    make -j$(nproc)
    make install -j$(nproc)
    
%runscript
    echo "Container GROMACS 2026.0 (GridUNESP Edition) Iniciado..."
    echo "Autor: Patrick Allan dos Santos Faustino"
    exec "$@"

%environment
    # --- Python (Ubuntu 24.04 usa v3.12) ---
    export PYTHONPATH=/usr/local/lib/python3.12/dist-packages:$PYTHONPATH

    # --- Variáveis do GROMACS (Definições) ---
    export GMXBIN=/usr/local/gromacs/bin
    export GMXLDLIB=/usr/local/gromacs/lib
    export GMXMAN=/usr/local/gromacs/share/man
    export GMXDATA=/usr/local/gromacs/share/gromacs
    
    # --- Atualização dos Caminhos (Tudo em uma linha só) ---
    # Ordem de prioridade: GROMACS -> CUDA -> Sistema
    export PATH=$GMXBIN:$PATH
    
    # Aqui consolidamos: Libs do GROMACS + Libs do CUDA + O que já existia
    export LD_LIBRARY_PATH=$GMXLDLIB:/usr/local/cuda/lib64:$LD_LIBRARY_PATH
    
    export MANPATH=$GMXMAN:$MANPATH

%labels
    Author "Patrick Allan dos Santos Faustino"
    Version "2026.02.14"
    Stack "Ubuntu 24.04 | CUDA 12 | GROMACS 2026.0 with NNPOT"

```

>[!WARNING]
> Mantenha sempre uma versão <= CUDA do contêiner em relação ao CUDA instalado no gridUNESP.
>

No arquivo [build.sh](gridunesp/build.sh), será enviado a tarefa de criar o contêiner para processamento do gridUNESP.

**[build.sh](gridunesp/build.sh):**
```
#!/bin/bash
#SBATCH -t 23:30:00
#SBATCH --job-name=apptainer
#SBATCH --cpus-per-task=16

export INPUT="gromacs-gpu.def"
export OUTPUT="*"
export VERBOSE="1"

job-nanny apptainer build ubuntu2404.sif gromacs-gpu.def

```
```
sbatch build.sh
```

>[!TIP]
> Faça o download e backup do arquivo `ubuntu2404.sif`. Esse arquivo é o contêiner criado e pode ser utilizado em qualquer computador compatível.
>


---
## 🔎 Check do Container

Caso queira realizar um check para verificar as versões das bibliotecas no contêiner e demais ajustes, utilize o arquivo [check.sh](gridunesp/check.sh) e [test.sh](gridunesp/test.sh).

```
sbatch test.sh
```

Verifique o arquivo `slurm-######.out` de saida para verificação.


---
## 💎 Dinâmicas moleculares no contêiner

Para a dinâmica, utilize os arquivos de exemplo [md1.sh](gridunesp/md1.sh) e [run1.sh](gridunesp/run1.sh).

**[md1.sh](gridunesp/md1.sh):**
```
!/bin/bash

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

```

**[run1.sh](gridunesp/run1.sh):**
```
#!/bin/bash
#SBATCH -t 23:30:00
#SBATCH --partition=gpu
#SBATCH --gres=gpu:2
#SBATCH --mem=16G
#SBATCH --job-name=job_
#SBATCH --cpus-per-task=16
#SBATCH --mail-user=patrick.faustino@unesp.br
#SBATCH --mail-type=BEGIN,END,FAIL

export INPUT="*"
export OUTPUT="*"
export VERBOSE="1"

module load gcc/14.3.0
module load cuda/12.9

# Executa o script de verificação dentro do container
job-nanny apptainer exec --nv ubuntu2404.sif bash md1.sh

```

```
sbatch run1.sh
```

---
## 🧰 Dicas para gridUNESP

```
ssh usuario@access.grid.unesp.br    # para acesso

squeue -u usuario    # lista tarefas do usuario
squeue -a            # lista todas as tarefas do grid

sbatch job.sh                 # submete a tarefa
scancel 00000000              # cancela a tarefa, onde 00000000 é o numero atribuido a tarefa
scontrol show job 00000000    # verifica detalhes da tarefa

sshare -a | grep usuario       # verifica o FairShare, quanto maior for, maior a prioridade.


squeue -o "%.18i %.9Q %.8j %.8u %.10V %.6D %R" --sort=-p,i --states=PD    # verifica a fila das próximas tarefas


tail -f slurm-00000000.out    # acompanha o processamento da tarefa
```


---

### 🧪⚗️ *Boas simulações moleculares!* 🦠🧬

---
## 📜 Citação

- FAUSTINO, Patrick Allan dos Santos. *Readme: Tutorials*. 2026. DOI 10.5281/zenodo.16062830. Disponível em: [https://github.com/patrickallanfaustino/tutorials-workstation/blob/main/gridunesp-ptbr.md](https://github.com/patrickallanfaustino/tutorials-workstation/blob/main/gridunesp-ptbr.md). Acesso em: 18 jul. 2025.
