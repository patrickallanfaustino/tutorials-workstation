# Workflow de Instalação Gromacs 2026.x com CUDA 13.x no Ubuntu 24.04 Noble Numbat

![GitHub repo size](https://img.shields.io/github/repo-size/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub language count](https://img.shields.io/github/languages/count/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub forks](https://img.shields.io/github/forks/patrickallanfaustino/tutorials?style=for-the-badge)

<img src="picture_2.png" alt="computer">

> Tutorial para compilar o GROMACS 2026.0 com suporte NNPOT-PyTorch (Redes Neurais) em GPU, utilizando CUDA 13.1 no Ubuntu 24.04.4 Kernel 6.17.

## 💻 Computador testado e pré-requisitos:
- CPU Ryzen 9 5900XT, Memória 2x16 GB DDR4, Chipset X570, GPU MSI RTX 4070 Ti Gaming Trio X, em dual boot com Windows 11.

Antes de começar, verifique se você atendeu aos seguintes requisitos:

- Você tem uma máquina linux `Ubuntu 24.04` com instalação limpa e atualizado.
- Você tem uma GPU série `Ada Lovelace`.
- Documentações [CUDA 13](https://docs.nvidia.com/cuda/index.html), [Drivers NVidia](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/introduction.html) e [GROMACS 2026.x](https://manual.gromacs.org/current/index.html).

Você vai precisar atualizar e instalar pacotes em sua máquina:
```
sudo apt update && sudo apt upgrade
sudo apt autoremove && sudo apt autoclean
sudo apt install build-essential libboost-all-dev git cmake cmake-curses-gui ttf-mscorefonts-installer
```

Para adicionar ferramentas necessárias ou atualizar com versões mais recentes:
```
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt update && sudo apt upgrade
```

Verifique também a versão do kernel (⚠️ versão = 6.8 ou 6.17):
```
uname -r
cat /etc/os-release
cmake --version
g++ --version
ldd --version
```

Verifique seu diretorio padrão `$HOME`, pois será o caminho utilizado para a maioria das instalações e configurações. Explore!

>[!TIP]
>
> Para instalar o Kernel 6.8 GA (General Availability):
> ```
> sudo apt install linux-image-generic
> ```
> 
> Para instalar o Kernel 6.17 HWE (Hardware Enablement):
> ```
> sudo apt install --install-recommends linux-generic-hwe-24.04
> ```
> 
> Para remover kernel antigos incompatíveis:
> ```
> dpkg --list | egrep -i --color 'linux-image|linux-headers'
> ```
>
> Para atualizar as versões do gcc e cmake (recomendado):
>```
>sudo apt install gcc-14 g++-14
>sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 100 --slave /usr/bin/g++ g++ /usr/bin/g++-14
>```
>```
>test -f /usr/share/doc/kitware-archive-keyring/copyright ||
>wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
>
>echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/>noble main' | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null
>
>sudo apt update
>```
>

Algumas configurações podem ajudar em sistemas dual boot:
```
# Instalar codecs, fontes e outros softwares
sudo apt install ubuntu-restricted-extras

# Conflitos de horários entre Windows e Ubuntu para casos de dualboot
timedatectl set-local-rtc 1 --adjust-system-clock

# Performance
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf

# Gerenciamento de memória
sudo apt install zram-config

# Acesso ao disco NTFS do Windows
sudo apt install ntfs-3g

# Reparo de boot GRUB. Selecione Recommended repair.
sudo add-apt-repository ppa:yannubuntu/boot-repair
sudo apt update
sudo apt install boot-repair
boot-repair
```

---
## 🔧 Instalando Timeshif

O [Timeshift](https://www.edivaldobrito.com.br/como-instalar-o-timeshift-no-ubuntu-linux-e-derivados/) é um software para criar backups. Recomendamos que seja criados backups para cada etapa completa. Para instalar o `Timeshift`, siga estas etapas:
```
sudo add-apt-repository ppa:teejee2008/timeshift
sudo apt update
sudo apt install timeshift
```

>[!TIP]
>
>Se desejar, instale o [GRUB CUSTOMIZER](https://www.edivaldobrito.com.br/grub-customizer-no-ubuntu/) para gerenciar o inicializador e [MAINLINE](https://www.edivaldobrito.com.br/como-instalar-o-ubuntu-mainline-kernel-installer-no-ubuntu-e-derivados/) para gerenciar o kernel instalado.
>
>```
>sudo add-apt-repository ppa:danielrichter2007/grub-customizer
>sudo apt update
>sudo apt install grub-customizer
>```
>
>```
>sudo add-apt-repository ppa:cappelikan/ppa
>sudo apt update
>sudo apt install mainline
>```
>

---
## 🔎 Instalando CUDA 13.x

Verifique a compatibilidade da GPU antes. Para CUDA 12 ou superior, requer arquitetura Maxwell ou superior.
```
lspci | grep -i nvidia
```

Remova todos os driver relacionados que tiver instalado:
```
sudo apt remove --autoremove --purge "*cuda*" "*cublas*" "*cufft*" "*cufile*" "*curand*" "*cusolver*" "*cusparse*" "*gds-tools*" "*npp*" "*nvjpeg*" "nsight*" "*nvvm*" "*nvidia*"
```
```
sudo apt autoremove --purge
```

Instale os pre-requisitos para CUDA:
```
sudo apt update
sudo apt install "linux-headers-$(uname -r)" "linux-modules-extra-$(uname -r)"
sudo apt install g++ freeglut3-dev build-essential ca-certificates software-properties-common dkms curl wget libx11-dev libxmu-dev libxi-dev libglu1-mesa-dev libfreeimage-dev libglfw3-dev
```

Adicionar o repositório oficial NVIDIA CUDA:
```
cd $HOME/Downloads
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
```
```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-archive-keyring.gpg
sudo mv cuda-archive-keyring.gpg /usr/share/keyrings/cuda-archive-keyring.gpg
```
```
echo "deb [signed-by=/usr/share/keyrings/cuda-archive-keyring.gpg] https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/ /" | tee /etc/apt/sources.list.d/cuda-ubuntu2404-amd64.list
```
```
sudo apt update
```

Para avaliar as versões de drivers e CUDA disponíveis:
```
apt search cuda-toolkit | grep -E "^cuda-toolkit"
apt search nvidia-driver | grep -E "^nvidia-driver-[0-9]+"
```

Instalação:
```
sudo apt install cuda-toolkit nvidia-driver-590 libnccl2 libnccl-dev
sudo apt install nvidia-gds
```

Para configurar o compilador NVCC, edite o `~/.bashrc` e adicione:
```
export CUDA_HOME=/usr/local/cuda-13.1
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
export PATH=$CUDA_HOME/bin:$PATH
```
```
source ~/.bashrc
sudo dkms autoinstall
reboot
```

Para verificar a instalação, utilize:
```
nvidia-smi
nvcc --version
```

>[!TIP]
>Para remover, utilize:
>
>```
>sudo apt remove --purge "*cuda*" "*nvidia*" cuda-keyring
>sudo apt purge && sudo apt autoremove && sudo apt autoclean
>```
>```
>sudo rm -f /etc/apt/preferences.d/cuda-repository-pin-600
>sudo rm -f /etc/apt/sources.list.d/cuda*.list
>sudo rm -rf /var/cache/apt/*
>sudo apt clean all
>sudo apt update
>sudo reboot
>```
>

---
## ⌚ Instalando LACT

O aplicativo [LACT](https://github.com/ilya-zlobintsev/LACT) é utilizado para controlar e realizar overclocking em GPU AMD, Intel e Nvidia em sistemas GNU/Linux.
```
cd $HOME/Downloads
wget https://github.com/ilya-zlobintsev/LACT/releases/download/v0.8.4/lact-0.8.4-0.amd64.ubuntu-2404.deb
sudo dpkg -i lact-0.8.4-0.amd64.ubuntu-2404.deb
sudo systemctl enable --now lactd
```

>[!WARNING]
>
>Faça o download do pacote [LACT](https://github.com/ilya-zlobintsev/LACT/releases/) de acordo com a distribuição do Linux.
>

>[!NOTE]
>
>Para remover versões anteriores, utilize `sudo dpkg -r lact`.
>

---
## 🎏 Instalando Hardware Sensors Indicator

O aplicativo [HSI](https://github.com/alexmurray/indicator-sensors) é utilizado para monitorar a temperatura de CPU, GPU, Motherboard, etc. Recomenda-se a instalação pela Central de Aplicativos [Snap](https://snapcraft.io/indicator-sensors) do Ubuntu e configurar para inicialização automatica com monitoramento da CPU (Tctl).
```
sudo snap install indicator-sensors
```

---
## 💎 Instalação do GROMACS 2026.x

**LIBTORCH!** É possivel instalar a biblioteca [libtorch](https://pytorch.org/) para utilizar Redes Neurais. Verifique a versão mais recente. Utilize a pasta `Downloads`.
```
cd $HOME/Downloads
wget https://download.pytorch.org/libtorch/cu130/libtorch-shared-with-deps-2.9.1%2Bcu130.zip
unzip libtorch-shared-with-deps-2.9.1+cu130.zip
```

Podemos instalar algumas bibliotecas auxiliares para o GROMACS:
```
sudo apt install grace \
hwloc \
texlive \
libhdf5-dev \
hdf5-tools \
libfftw3-dev \
libopenblas-dev \
imagemagick \
libpng-dev \
libjpeg-dev \
libtiff-dev \
libxml2-dev \
libtinyxml2-dev \
libzstd-dev \
zlib1g-dev
```

A partir de agora, você poderá seguir a documentação oficial [guia de instalação](https://manual.gromacs.org/current/install-guide/index.html).
```
cd $HOME/Downloads
wget ftp://ftp.gromacs.org/gromacs/gromacs-2026.0.tar.gz
tar -xvf gromacs-2026.0.tar.gz
cd gromacs-2026.0
sudo mkdir build && cd build
```

Para compilar com Cmake (versão >=3.28):
```
sudo cmake .. \
-DCMAKE_BUILD_TYPE=Release \
-DGMX_BUILD_OWN_FFTW=ON \
-DREGRESSIONTEST_DOWNLOAD=ON \
-DGMX_THREAD_MPI=ON \
-DCMAKE_C_FLAGS="-O3 -march=native -mtune=native" \
-DCMAKE_CXX_FLAGS="-O3 -march=native -mtune=native" \
-DGMX_GPU=CUDA \
-DCUDAToolkit_ROOT=/usr/local/cuda \
-DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda \
-DCMAKE_CUDA_ARCHITECTURES=native \
-DCMAKE_INSTALL_PREFIX=$HOME/gromacs-cuda-torch \
-DGMX_HWLOC=ON \
-DGMX_USE_HDF5=ON \
-DGMX_USE_PLUMED=ON \
-DGMX_USE_COLVARS=INTERNAL \
-DGMX_NNPOT=TORCH \
-DGMX_EXTERNAL_TINYXML2=ON \
-DGMX_EXTERNAL_ZLIB=ON \
-DCMAKE_PREFIX_PATH="$HOME/Downloads/libtorch;/usr/local/cuda"
```

Note que criei uma pasta chamada `gromacs-cuda-torch` para os arquivos compilados e indiquei com `-DCMAKE_INSTALL_PREFIX`, pois isso facilita a atualização do GROMACS no futuro.

Agora é o momento de compilar, checar e instalar:
```
sudo make -j$(nproc)
sudo make check -j$(nproc)
sudo make install -j$(nproc)
```

Para carregar a biblioteca e invocar o GROMACS:
```
source $HOME/gromacs-cuda-torch/bin/GMXRC
gmx -version
```

>[!TIP]
>
>Você poderá editar o arquivo `$HOME/.bashrc` e adicionar o código `source $HOME/gromacs-cuda-torch/bin/GMXRC`. Assim, toda vez que abrir o terminal carregara o GROMACS.
>

---
## 🐍 Instalando ANACONDA e PyTorch

O [Anaconda](https://www.anaconda.com) é um importante pacote de bibliotecas Python voltados para o uso científico.
```
cd $HOME/Downloads
wget https://repo.anaconda.com/archive/Anaconda3-2025.12-2-Linux-x86_64.sh
bash Anaconda3-2025.12-2-Linux-x86_64.sh
source ~/.bashrc
conda config --set auto_activate_base false
conda info
```

Com os comandos acima será carregado no prompt (`source ~/.bashrc`) o conda `base`. Para desativar o carregamento automatico, utilizar `conda config --set auto_activate_base false`.

>[!TIP]
>
>Faça o download do pacote [Anaconda](https://www.anaconda.com/download) mais recente.
>

>[!WARNING]
>
>Certifique de que a instalação será no diretório `$HOME/anaconda3` confirmando `yes` para todas as respostas. **NÃO UTILIZE `sudo`**.
>

Agora, vamos criar um ambiente virtual e instalar o [Pytorch](https://pytorch.org/get-started/locally/). No diretório `$HOME`, crie um ambiente `gromacs-nnpot`:
```
cd $HOME
sudo apt install python3-venv libjpeg-dev python3-dev python3-pip
python3 -m venv gromacs-nnpot
source $HOME/gromacs-nnpot/bin/activate
python3 -m pip install --upgrade setuptools pip wheel
pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cu130
```

Para testar:
```
python3 -c 'import torch' 2> /dev/null && echo 'Success' || echo 'Failure' # retorna Success
python3 -c "import torch; print(torch.cuda.is_available())"                # retorna True
python3 -c "import torch; print(torch.cuda.get_device_properties(0))"      # retorna informações GPU
python3 -c "import torch; x = torch.rand(5, 3); print(x)"                  # retorna matriz
python3 -c "import torch; print(torch.__version__)"                        # retorna a versão do Torch
```

>[!TIP]
>
>Caso deseje desistalar utilize `pip3 uninstall <biblioteca>`, para atualizar `pip3 install --upgrade <biblioteca>` e para listar os pacotes instalados `pip3 list`.
>

---

## 💎 Instalação do OpenMM 8.x

O [OpenMM](https://openmm.org/) é outro software baseado em Python para simulação de dinâmica molecular. Para sua instalação, vamos criar um ambiente virtual e instalar via pip no diretório padrão `$HOME`.
```
cd $HOME
python3 -m venv openmm
source $HOME/openmm/bin/activate
pip3 install openmm[cuda13]
```

Para sair do ambiente criado, basta utilizar `deactivate`. Para verificar a instalação, onde será realizado teste com a Referência, CPU, HIP e OpenCL:
```
python -m openmm.testInstallation
```

>[!NOTE]
>***Extra:*** para compilar no Conda com suporte Torch:
>```
>conda create --name openmm-conda
>conda activate openmm-conda
>conda install -c conda-forge openmm cuda-version=13 openmmforcefields openmm-torch openmm-ml
>```
>

Para remover o ambiente conda criado `conda env remove --name openmm-conda` e para listar todas os ambientes utilize `conda env list`.

---
## 🧬 Instalando VMD e Pymol

O [VMD](https://www.ks.uiuc.edu/Development/Download/download.cgi?PackageName=VMD) permite visualizar moléculas e realizar análises. Para instalação:
```
cd $HOME
wget https://www.ks.uiuc.edu/Research/vmd/alpha/vmd-2.0.0a9.bin.LINUXAMD64.tar.gz
tar xvzf vmd-2.0.0a9.bin.LINUXAMD64.tar.gz
cd  vmd-2.0.0a9
./configure
cd src
sudo make install -j$(nproc)
vmd
```

O [Pymol](https://www.pymol.org/) é outro software muito utilizado para visualização de moléculas:
```
sudo snap install pymol-oss
```

---
## 🧮 Instalando o Julia

O [Julia](https://julialang.org/) é uma linguagem de programação voltada para cálculos científicos, similar ao Python. Para instalar:

```
cd $HOME
sudo apt install curl
curl -fsSL https://install.julialang.org | sh
```

Para atualizar, utilize no terminal `juliaup update`.

---
## 🧰 Instalando ferramentas para topologias: OpenBabel, AmberTools/ACPYPE, CGenFF, LigParGen e Packmol.

>[!NOTE]
>A adoção de ambientes isolados visa assegurar a manutenção e mitigar incompatibilidades entre bibliotecas.
>

[OpenBabel](https://openbabel.org/docs/index.html) é um pacote usado para manipular dados de modelagem molecular, química, etc. Para instalar:

```
sudo apt install openbabel
obabel --version
```

Para uso:
```
obabel -ismi ethanol.smi -opdb -O ethanol.pdb --title ETHANOL --gen3d --minimize --sd --ff GAFF --log

ou

obabel -:'CCO' -ogro -O ethanol.gro --title ETHANOL --gen3d --minimize --sd --ff GAFF --log
```

>[!NOTE]
>***Extra:*** para mais informações sobre todas as funções disponiveis, consulte `obabel -Hall`.
>

[AmberTools](https://ambermd.org/AmberTools.php) é uma coleção de programas gratuitos e de código aberto usados ​​para configurar, executar e analisar simulações moleculares.. Para instalar:

```
cd $HOME
conda create --name acpype
conda activate acpype
conda install --channel conda-forge ambertools openbabel
```

Em conjunto com o AmberTools, o [ACPYPE](https://github.com/alanwilter/acpype) é um pacote em python para gerar topologias de moléculas. Para instalar e utilizar:

```
pip install acpype
acpype --version

acpype -i ethanol.mol2               # exemplo de uso para uma molécula de etanol.
```

[CGenFF](https://cgenff.com/) é um servidor web para gerar topologias de moléculas para o campo de força CHARMM36. É possivel obter as topologias e coordenadas diretamente no formato para Gromacs ou obter o arquivo `.str` para posterior conversão em ambiente. É necessário obter a molécula de interesse no formato `.mol2`.

```
conda create --name cgenff python=3.7
conda activate cgenff
conda install networkx=2.3 numpy

python cgenff_charmm2gmx_py3_nx2.py ETH ethanol.mol2 ethanol.str charmm36-jul2022.ff     # o campo de força deverá estar no mesmo diretório de trabalho.
```

[LigPargen](https://github.com/Isra3l/ligpargen/tree/main) é uma biblioteca desenvolvida para gerar topologias de moléculas para o campo de força OPLS. Faça o download do software [BOSS](https://traken.chem.yale.edu/software.html), descompacte em um diretório de trabalho.

```
sudo apt install csh
export BOSSdir=PATH_TO_BOSS_DIRECTORY            # pode ser incluido no arquivo ~/.bashrc
```

Para criar o ambiente e instalar:

```
conda create --name ligpargen python=3.7
conda activate ligpargen
conda install -c rdkit rdkit
conda install --channel conda-forge openbabel
```
```
cd $HOME
git clone https://github.com/Isra3l/ligpargen.git
pip install -e ligpargen
cd ligpargen
python -m unittest test_ligpargen/test_ligpargen.py
ligpargen -h
```

Para gerar topologia de moléculas, utilize:

```
ligpargen -s 'CCO' -n ethanol -p molecule -r ETH -c 0 -o 3 -cgen CM1A-LBCC -verbose -check

ou

ligpargen -i ethanol.pdb -n ethanol -p molecule -r ETH -c 0 -o 3 -cgen CM1A-LBCC -verbose -check
```

[Packmol](https://m3g.github.io/packmol/) é uma biblioteca criada para construir configurações iniciais de sistemas complexos para simulação. Para instalar:
```
cd $HOME
python3 -m venv packmol
source $HOME/packmol/bin/activate
pip install packmol
```

---

## 🧰 Instalando ferramentas para análises: Alchemlyb/PyMBAR, MDAnalysis, MDTraj, PyEMMA e GMX_MMPBSA.

>[!NOTE]
>A adoção de ambientes isolados visa assegurar a manutenção e mitigar incompatibilidades entre bibliotecas.
>

[Alchemlyb](https://github.com/alchemistry/alchemlyb) é uma biblioteca voltado para análises de energia livres altamente eficiente, utilizando aprendizagem de máquina nas análises. Para instalar:

```
cd $HOME
python3 -m venv mbar
source $HOME/mbar/bin/activate
pip install alchemlyb jax pymbar pandas pybar[jax]
```

[MDAnalysis](https://www.mdanalysis.org/) é "agnóstica" quanto ao formato de arquivo (lê GROMACS, Amber, CHARMM, NAMD, etc. sem precisar converter). É orientada a objetos, permitindo seleções de átomos muito complexas e poderosas. É excelente para escrever ferramentas de análise personalizadas, embora possa ser ligeiramente mais lenta que o MDTraj em cálculos massivos.

```
conda create --name mdanalysis
conda activate mdanalysis
conda install -c conda-forge mdanalysis
```

[MDTraj](https://www.mdtraj.org/1.9.8.dev0/index.html) projetada para ser extremamente rápida e eficiente em memória, utiliza arrays do NumPy nativamente. É ideal para processar grandes volumes de dados (Big Data) e para converter formatos de trajetória. É frequentemente a escolha preferida para alimentar pipelines de Machine Learning devido à sua integração fácil com o ecossistema Scikit-learn/NumPy.

```
conda create --name mdtraj
conda activate mdtraj
conda install -c conda-forge mdtraj
```

[PyEMMA](http://emma-project.org/latest/) usada para analisar a cinética e a termodinâmica de sistemas moleculares. Ela pega dados de simulação (frequentemente processados via MDTraj) e ajuda a identificar estados metaestáveis, barreiras de energia e taxas de transição. É muito usada para entender folding de proteínas ou mudanças conformacionais complexas através de redução de dimensionalidade (TICA).

```
conda create --name pyemma
conda activate pyemma
conda install -c conda-forge pyemma
```

[gmx_MMPBSA](https://valdes-tresanco-ms.github.io/gmx_MMPBSA/dev/) utiliza os métodos MM/PBSA (Molecular Mechanics Poisson-Boltzmann Surface Area) e MM/GBSA para calculos de energias livres.

```
sudo apt install openmpi-bin libopenmpi-dev openssh-client
conda create -n gmxMMPBSA python=3.11.8
conda activate gmxMMPBSA
conda install -c conda-forge "mpi4py=4.0.1" "ambertools<=23.6"
conda install -c conda-forge numpy matplotlib scipy pandas seaborn
python -m pip install "pyqt6==6.7.1" "parmed"
python -m pip install gmx_MMPBSA

gmx_MMPBSA --version
```
Para configurar o Autocompletion, edite no `.bashrc` e adicione:
```
export GMX_COMP_PATH=$HOME/anaconda3/envs/gmxMMPBSA/lib/python3.11/site-packages/GMXMMPBSA/GMXMMPBSA.sh

chmod +x $GMX_COMP_PATH

if [ -f "$GMX_COMP_PATH" ]; then
    source "$GMX_COMP_PATH"
fi
```
Para testar:
```
gmx_MMPBSA_test -f $HOME/Documentos -n 16
```

---

### 🧪⚗️ *Boas simulações moleculares!* 🦠🧬

---
## 📜 Citação

- FAUSTINO, Patrick Allan dos Santos. *Readme: Tutorials*. 2026. DOI 10.5281/zenodo.16062830. Disponível em: [https://github.com/patrickallanfaustino/tutorials-workstation/blob/main/cuda-gromacs-ptbr.md](https://github.com/patrickallanfaustino/tutorials-workstation/blob/main/cuda-gromacs-ptbr.md). Acesso em: 18 jul. 2025.

- Fonte auxiliar: [How to Install CUDA on Ubuntu](https://linuxcapable.com/how-to-install-cuda-on-ubuntu-linux/)
