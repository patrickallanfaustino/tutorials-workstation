# Workflow Install Gromacs 2025.x com ROCm 6.3.3 e AdaptiveCpp 24.x no Ubuntu 24.04 Noble Numbat

![GitHub repo size](https://img.shields.io/github/repo-size/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub language count](https://img.shields.io/github/languages/count/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub forks](https://img.shields.io/github/forks/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub Release](https://img.shields.io/github/v/release/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub Tag](https://img.shields.io/github/v/tag/patrickallanfaustino/tutorials?style=for-the-badge)

<img src="picture_1.png" alt="computer">

> Tutorial para compilar o Gromacs 2025.1 com suporte NNPOT-PyTorch (Redes Neurais), usando AdaptiveCpp 24.10 em backend e ROCm 6.3.3 no Ubuntu 24.04 Kernel 6.11, para utilizar aceleração GPU AMD RDNA2 em desktop.

## 💻 Computador testado e Pré-requisitos:
- CPU Ryzen 9 5900XT, Memória 2x16 GB DDR4, Chipset X470, GPU ASRock RX 6600 CLD 8 GB, dual boot com Windows 11 e Ubuntu 24.04 instalados em SSD's separados.

Antes de começar, verifique se você atendeu aos seguintes requisitos:

- Você tem uma máquina linux `Ubuntu 24.04` com instalação limpa e atualizado.
- Você tem uma GPU série `AMD RX 6xxx RDNA2`. Não testado com outras arquiteturas.
- Documentações [ROCm 6.3.3](https://rocm.docs.amd.com/projects/install-on-linux/en/docs-6.3.3/index.html), [AdaptiveCpp 24.xx](https://github.com/AdaptiveCpp/AdaptiveCpp) e [Gromacs 2025.1](https://manual.gromacs.org/current/index.html).

Você também vai precisar atualizar e instalar pacotes em sua máquina:

```
sudo apt update && sudo apt upgrade
sudo apt autoremove && sudo apt autoclean
sudo apt install build-essential
```

Para adicionar ferramentas necessárias ou atualizar com versões mais recentes:

```
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt update && sudo apt upgrade
```

Verifique também a versão do kernel (versão >= 6.8):
```
uname -r
```

---
## 🔧 Instalando Timeshif

O [Timeshift](https://www.edivaldobrito.com.br/como-instalar-o-timeshift-no-ubuntu-linux-e-derivados/) é um software para criar backups. Recomendamos que seja criada backups para cada etapa. Para instalar o `Timeshift`, siga estas etapas:

```
sudo add-apt-repository ppa:teejee2008/timeshift
sudo apt update
sudo apt install timeshift
```

>[!TIP]
>
>Se desejar, pode-se instalar o [GRUB CUSTOMIZER](https://www.edivaldobrito.com.br/grub-customizer-no-ubuntu/) para gerenciar o inicializador e [MAINLINE](https://www.edivaldobrito.com.br/como-instalar-o-ubuntu-mainline-kernel-installer-no-ubuntu-e-derivados/) para gerenciar kernel instalados.
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
## 🔎 Instalando ROCm 6.3.3

Recomenda-se realizar todas as instalações na pasta `Downloads`.Vamos instalar o `rocm 6.3.3`.

```
sudo apt install "linux-headers-$(uname -r)" "linux-modules-extra-$(uname -r)"
sudo apt install python3-setuptools python3-wheel
wget https://repo.radeon.com/amdgpu-install/6.3.3/ubuntu/noble/amdgpu-install_6.3.60303-1_all.deb
sudo apt install ./amdgpu-install_6.3.60303-1_all.deb && sudo apt update
sudo amdgpu-install --usecase=rocm,rocmdev,hip,hiplibsdk
sudo usermod -a -G render,video $LOGNAME
```
```
echo ‘ADD_EXTRA_GROUPS=1’ | sudo tee -a /etc/adduser.conf
echo ‘EXTRA_GROUPS=video’ | sudo tee -a /etc/adduser.conf
echo ‘EXTRA_GROUPS=render’ | sudo tee -a /etc/adduser.conf
```
```
reboot
```

Para verificar a instalação, utilize:

```
groups
sudo clinfo
sudo rocminfo
sudo rocm-smi
```

> [!IMPORTANT]  
>Quando printar `rocminfo`, verificar o nome da placa que no geral será apresentado como `gfx1032` (para RX 6600).
> 

Pode ser necessário a instalação da biblioteca `rocm-llvm-dev`:
```
sudo apt install rocm-llvm-dev
```

A GPU deverá ser identificada. Caso não consiga, experimente `reboot` e verifique novamente. Instalação ficará em `PATH=/opt/rocm`.

>[!TIP]
>
>Utilize o comando abaixo para listar todos os `cases` disponíveis no `amdgpu-install`:
>
>```
>sudo amdgpu-install --list-usecase
>```
>
>Para remover `amdgpu-install`, utilize:
>
>```
>sudo amdgpu-install --uninstall --rocmrelease=all
>sudo apt purge amdgpu-install && sudo apt autoremove && sudo apt autoclean
>```
>```
>sudo rm /etc/apt/sources.list.d/amdgpu.list
>sudo rm /etc/apt/sources.list.d/rocm.list
>sudo rm -rf /var/cache/apt/*
>sudo apt clean all
>sudo apt update
>sudo reboot
>```
>
---
## ⌚ Instalando LACT

O aplicativo [LACT](https://github.com/ilya-zlobintsev/LACT) é utilizado para controlar e realizar overclocking em GPU AMD, Intel e Nvidia em sistemas Linux.

```
wget https://github.com/ilya-zlobintsev/LACT/releases/download/v0.7.3/lact-0.7.3-0.amd64.ubuntu-2404.deb
sudo dpkg -i lact-0.7.3-0.amd64.ubuntu-2404.deb
sudo systemctl enable --now lactd
```
**AMD Overclocking:** ative a função no LACT.

>[!TIP]
>
>Faça o download do pacote do [LACT](https://github.com/ilya-zlobintsev/LACT/releases/) de acordo com a distribuição do Linux.
>

---
## 🔨 Instalando AdaptiveCpp 24.xx

O `AdaptiveCpp 24.xx` irá trabalhar em backend com `rocm 6.3.3`. Recomenda-se o uso da pasta `Downloads`. Para instalar:
```
sudo apt install -y libboost-all-dev git cmake
```
```
git clone https://github.com/AdaptiveCpp/AdaptiveCpp
cd AdaptiveCpp
sudo mkdir build && cd build
```

Para compilar com CMake (versão >=3.28):
```
sudo cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local \
-DCMAKE_C_COMPILER=/opt/rocm/llvm/bin/clang \
-DCMAKE_CXX_COMPILER=/opt/rocm/llvm/bin/clang++ \
-DLLVM_DIR=/opt/rocm/llvm/lib/cmake/llvm/ \
-DWITH_ROCM_BACKEND=ON \
-DWITH_SSCP_COMPILER=OFF \
-DWITH_OPENCL_BACKEND=OFF \
-DWITH_LEVEL_ZERO_BACKEND=OFF \
-DWITH_CUDA_BACKEND=OFF \
-DDEFAULT_TARGETS='hip:gfx1032'
```
```
sudo make install -j$(nproc)
```

Para verificar a instalação, `acpp-info` deverá apresentar as informações da GPU:
```
acpp-info
```

>[!NOTE]
>
>**Meu Caso**: No `sudo make install -j$(nproc)`, a tag `-j32` define a quantidade de CPUs utilizadas na compilação. Poderá omitir `-j$(nproc)`.
>

>[!WARNING]
>
>Sempre fique atento aos caminhos de endereçamentos, *i.e* `/path/to/user/...`, porque são os maiores causadores de erros durante as compilações.
>
---
## 💎 Instalação do Gromacs 2025.x

**LIBTORCH!** É possivel instalar a biblioteca [libtorch](https://pytorch.org/) para utilizar Redes Neurais. Verifique a versão mais recente. Utilize a pasta `Downloads`.
```
wget https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-2.6.0%2Bcpu.zip
unzip libtorch-cxx11-abi-shared-with-deps-2.6.0%2Bcpu.zip
```

Podemos instalar algumas bibliotecas auxiliares para o Gromacs:
```
sudo apt install grace hwloc texlive
```

A partir de agora, você poderá seguir a documentação [guia de instalação](https://manual.gromacs.org/current/install-guide/index.html) do Gromacs.
```
wget ftp://ftp.gromacs.org/gromacs/gromacs-2025.1.tar.gz
tar -xvfz gromacs-2025.1.tar.gz
cd gromacs-2025.1
sudo mkdir build && cd build
```
Para compilar com Cmake (versão >=3.28):
```
sudo cmake .. -DGMX_BUILD_OWN_FFTW=ON \
-DREGRESSIONTEST_DOWNLOAD=ON \
-DCMAKE_C_COMPILER=/opt/rocm/llvm/bin/clang \
-DCMAKE_CXX_COMPILER=/opt/rocm/llvm/bin/clang++ \
-DGMX_GPU=SYCL \
-DGMX_SYCL=ACPP \
-DCMAKE_INSTALL_PREFIX=/home/patrickfaustino/gromacs \
-DHIPSYCL_TARGETS='hip:gfx1032' \
-DGMX_HWLOC=ON \
-DGMX_USE_PLUMED=ON \
-DGMX_NNPOT=TORCH \
-DCMAKE_PREFIX_PATH="/home/patrickfaustino/Downloads/libtorch"
```
Note que criei uma pasta chamada `gromacs` para os arquivos compilados e indiquei com `-DCMAKE_INSTALL_PREFIX`. 

>[!NOTE]
>
>**Meu Caso**: Atenção ao `-DHIPSYCL_TARGETS='hip:gfxABC'`, substitua com os seus valores.
>

Agora é o momento de compilar, checar e instalar:
```
sudo make -j$(nproc)
sudo make check -j$(nproc)
sudo make install -j$(nproc)
```

Para carregar a biblioteca e invocar o Gromacs:
```
source /home/patrickfaustino/gromacs/bin/GMXRC
gmx -version
```

>[!WARNING]
>
>Durante `sudo make check -j$(nproc)` ocorreram erros por TIMEOUT. Prossegui e testei uma dinâmica simples e não houve nenhum problema. Aparentemente, usuários do Gromacs 2024/2025 enfrentam esses problemas e com `-DGMX_TEST_TIMEOUT_FACTOR=2` pode dar mais tempo para o teste.
>

>[!TIP]
>
>Você poderá editar o arquivo `/home/patrickfaustino/.bashrc` e adicionar o código `source /home/patrick/gromacs/bin/GMXRC`. Assim, toda vez que abrir o terminal já irá carregar o Gromacs.
>

---
## 🐍 Instalando ANACONDA e PyTorch

O [Anaconda](https://www.anaconda.com/download) é um importante pacote de bibliotecas voltados para o uso científico, escritos em python. Para instalação, recomendamos a pasta `Downloads`:

```
wget https://repo.anaconda.com/archive/Anaconda3-2024.06-1-Linux-x86_64.sh
bash Anaconda3-2024.06-1-Linux-x86_64.sh
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
>Certifique de que a instalação será no path `home/patrickfaustino/anaconda3`, confirmando `yes` para todas as respostas. Não utilize `sudo`.
>

Agora, vamos criar um ambiente virtual e instalar o [Pytorch](https://pytorch.org/get-started/locally/). No diretório /home/patrickfaustino, crie um ambiente `gromacs-nnpot`:
```
sudo apt install python3-venv libjpeg-dev python3-dev python3-pip
python3 -m venv gromacs-nnpot
source gromacs-nnpot/bin/activate
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.2.4
```
Para testar:
```
python3 -c 'import torch' 2> /dev/null && echo 'Success' || echo 'Failure'
python3 -c "import torch; print(torch.cuda.is_available())" 
python3 -c "import torch; print(torch.cuda.get_device_properties(0))"
python3 -c "import torch; x = torch.rand(5, 3); print(x)" 
```

>[!TIP]
>
>Embora a versão do Pytorch-rocm 6.2.4 seja diferente do rocm instalado, durante os testes não houve problemas. Os testes deverão retornar valores positivos de sucesso.
>Caso deseje desistalar utilize `pip3 uninstall <biblioteca>`, para atualizar `pip3 upgrade <biblioteca>` e para listar os pacotes instalados `pip3 list`.
>

### 🧪🧬⚗️ *Boas simulações moleculares!*

## 📜 Citação

- FAUSTINO, P. A. S. Tutorials: Workflow Install Gromacs 2025.x com ROCm 6.3.3 e AdaptiveCpp 24.x no Ubuntu 24.04 Noble Numbat, 2025. README. Disponível em: <[https://github.com/patrickallanfaustino/tutorials-workstation/blob/main/rocm-acpp-gromacs.md](https://github.com/patrickallanfaustino/tutorials-workstation/blob/main/rocm-acpp-gromacs-ptbr.md)>. Acesso em: [dia] de [mês] de [ano].
- Fonte auxiliar: [Install workflow with AMD GPU support (Framework 16, Ubuntu 24.04, GPU: AMD Radeon RX 7700S)](https://gromacs.bioexcel.eu/t/install-workflow-with-amd-gpu-support-framework-16-ubuntu-24-04-gpu-amd-radeon-rx-7700s/10870)

---
## 📝 Licença

Esse projeto está sob licença. Veja o arquivo [LICENÇA](LICENSE.md) para mais detalhes.
