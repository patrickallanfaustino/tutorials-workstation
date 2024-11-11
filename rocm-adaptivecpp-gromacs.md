# Compilando ROCm com HIPSyCL (AdaptiveCpp) no Ubuntu 22.04 para Gromacs 2024

![GitHub repo size](https://img.shields.io/github/repo-size/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub language count](https://img.shields.io/github/languages/count/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub forks](https://img.shields.io/github/forks/patrickallanfaustino/tutorials?style=for-the-badge)
![Bitbucket open issues](https://img.shields.io/bitbucket/issues/patrickallanfaustino/tutorials?style=for-the-badge)
![Bitbucket open pull requests](https://img.shields.io/bitbucket/pr-raw/patrickallanfaustino/tutorials?style=for-the-badge)

<img src="imagem1.png" alt="computer">

> Tutorial para compilar ROCm 5.7.1 e HipSyCL (AdaptiveCpp 24.04) no Ubuntu 22.04 para utilizar GPUs Navi23 RDNA no Gromacs 2024.

## 💻 Computador testado e Pré-requisitos:
- CPU Ryzen 7 2700X, Memória 2x16 GB DDR4, Chipset X470, GPU ASRock RX 6600 CLD 8 GB, dual boot com Windows 11 e Ubuntu 22.04 instalados em SSD's separados.

Antes de começar, verifique se você atendeu aos seguintes requisitos:

- Você tem uma máquina `Linux Ubuntu 22.04` atualizado.
- Você tem uma GPU série `RX 6xxx RDNA 2`. Não testado com outras arquiteturas.
- Documentações [ROCm 5.7.1](https://rocm.docs.amd.com/en/docs-5.7.1/), [AdaptiveCpp 24.06](https://github.com/AdaptiveCpp/AdaptiveCpp).

Você também vai precisar atualizar e instalar pacotes em sua máquina:

```
sudo apt update && sudo apt upgrade -y
```
```
sudo apt install cmake libboost-all-dev git build-essential libstdc++-12-dev
```
```
sudo apt autoremove && sudo apt autoclean
```

## 🔧 Instalando Kernel 5.15 generic

Para instalar o `Kernel 5.15 generic` no Ubuntu 22.04, siga estas etapas:

```
sudo apt install linux-image-generic
```

Adicione os headers e módulos extras do Kernel:

```
sudo apt install "linux-headers-$(uname -r)" "linux-modules-extra-$(uname -r)"
```

Em seguida e *nessa ordem*, altere para usar o Kernel 5.15 e remova os demais Kernels instalados. Essa tarefa pode ser feita com o [GRUB CUSTOMIZER](https://www.edivaldobrito.com.br/grub-customizer-no-ubuntu/) ou no terminal. Existe vasto material na internet para auxiliar nessa tarefa, aqui coloco apenas o objetivo principal que é instalar e usar o Kernel 5.15 na máquina.

>[!NOTE]
>
>**Meu Caso**: Com dual boot, então realizei um reboot e utilizei o GRUB para alterar o Kernel. Depois `sudo dpkg -l | grep linux-image`, `sudo apt remove` e `sudo apt autoremove && sudo apt autoclean` para, respectivamente, listar e remover os outros Kernels instalados.

>[!TIP]
>
>O comando abaixo ajudará a identificar o Kernel instalado:
>
>```
>uname -r
>```

## 🪛 Instalando ROCm 5.7.1

Vamos instalar o `ROCm 5.7.1`. Precisaremos dar previlégios ao usuário e adicioná-lo a grupos:

```
sudo usermod -a -G render,video $LOGNAME
```
```
echo ‘ADD_EXTRA_GROUPS=1’ | sudo tee -a /etc/adduser.conf
```
```
echo ‘EXTRA_GROUPS=video’ | sudo tee -a /etc/adduser.conf
```
```
echo ‘EXTRA_GROUPS=render’ | sudo tee -a /etc/adduser.conf
```

Download e instalação do pacote `ROCm 5.7.1`:

```
https://repo.radeon.com/amdgpu-install/5.7.1/ubuntu/jammy/amdgpu-install_5.7.50701-1_all.deb
```
```
sudo apt install ./amdgpu-install_5.7.50701-1_all.deb
```

Utilizando o `amdgpu-install`, instalar o pacote `rocm,hip,hiplibsdk`:

```
sudo amdgpu-install --usecase=rocm,hip,hiplibsdk
```

Atualizar todos os índices e links de bibliotecas:

```
sudo ldconfig
```

Para verificar a instalação, utilize:

```
sudo clinfo
```
```
sudo rocminfo
```

A GPU deverá ser identificada. Caso não consiga, experimente `reboot` e verifique novamente.

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
>amdgpu-uninstall
>```
>```
>sudo apt purge amdgpu-install
>```
>
> Instalação ficará em `PATH=/opt/rocm`

## 🔨 Instalação LLVM e bibliotecas

O `AdaptiveCpp` requer LLVM e algumas bibliotecas. Para instalar, faça:

```
wget https://apt.llvm.org/llvm.sh
```
```
sudo chmod +x llvm.sh
```
```
sudo ./llvm.sh 16
```
```
sudo apt install -y libclang-16-dev clang-tools-16 libomp-16-dev llvm-16-dev lld-16
```

## 🪚 Instalação do AdaptiveCpp 24.06

O `AdaptiveCpp 24.06` irá trabalhar em backend com `ROCm 5.7.1`. Ele contém o `SyCL`. Para instalar:

```
git clone https://github.com/AdaptiveCpp/AdaptiveCpp
```
```
cd AdaptiveCpp
```
```
sudo mkdir build && cd build
```

Para compilar com CMake:

```
sudo cmake .. -DCMAKE_INSTALL_PREFIX=/home/patrick/hipsycl -DCMAKE_C_COMPILER=/opt/rocm/llvm/bin/clang -DCMAKE_CXX_COMPILER=/opt/rocm/llvm/bin/clang++ -DLLVM_DIR=/opt/rocm/llvm/lib/cmake/llvm/ -DROCM_PATH=/opt/rocm -DWITH_ROCM_BACKEND=ON -DWITH_SSCP_COMPILER=OFF -DWITH_OPENCL_BACKEND=OFF -DWITH_LEVEL_ZERO_BACKEND=OFF -DDEFAULT_TARGETS='hip:gfx1032'
```
```
sudo make install -j 16
```

>[!NOTE]
>
>**Meu Caso**: Recomendo criar pastas para as compilações, assim se algo der errado é só apagar. Criei a pasta `hipsycl` com `sudo mkdir hipsycl` e defini em `-DCMAKE_INSTALL_PREFIX` ao compilar. Em `-DDEFAULT_TARGETS` completar `ABC` em `hip:gfx1ABC` com a informação da obtida em `clinfo` ou `rocminfo`. Esse código corresponde ao endereçamento da GPU.
> No `sudo make install -j 16`, a tag `-j` seguida de número define a quantidade de CPUs utilizadas na compilação.

>[!WARNING]
>
>Sempre fique atento aos endereçamentos, *i.e* `/path/to/user/...`, porque são eles os maiores causadores de erros.


## 💎 Instalação do Gromacs 2024.x

**OPCIONAL!** Antes de instalar o Gromacs, você talvez queira instalar algumas bibliotecas que ajudam o Gromacs, melhorando o desempenho.

```
sudo apt install libhwloc-dev hwloc grace liblapack64-dev libblas64-dev
```

A partir de agora, você poderá seguir a documentação [guia de instalação](https://manual.gromacs.org/current/install-guide/index.html) do Gromacs. No momento de compilar com CMake, utilize:

```
sudo cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON -DCMAKE_C_COMPILER=/opt/rocm/llvm/bin/clang -DCMAKE_CXX_COMPILER=/opt/rocm/llvm/bin/clang++ -DHIPSYCL_TARGETS='hip:gfx1032' -DGMX_GPU=SYCL -DGMX_SYCL=ACPP -DCMAKE_INSTALL_PREFIX=/home/patrick/gromacs -DCMAKE_PREFIX_PATH=/home/patrick/hipsycl -DSYCL_CXX_FLAGS_EXTRA=-DHIPSYCL_ALLOW_INSTANT_SUBMISSION=1 -DGMX_EXTERNAL_BLAS=on -DGMX_EXTERNAL_LAPACK=on -DGMX_BLAS_USER=/usr/lib/x86_64-linux-gnu/blas64/libblas64.so -DGMX_LAPACK_USER=/usr/lib/x86_64-linux-gnu/lapack64/liblapack64.so
```
Novamente, criei uma pasta chamada `gromacs` para os arquivos compilados e indiquei com `-DCMAKE_INSTALL_PREFIX`. 

>[!NOTE]
>
>**Meu Caso**: Utilizei outras bibliotecas para os cálculos `BLAS64` e `LAPACK64`, indiquei com `-DGMX_EXTERNAL_BLAS -DGMX_EXTERNAL_LAPACK -DGMX_BLAS_USER -DGMX_LAPACK_USER`. Atenção ao `-DHIPSYCL_TARGETS='hip:gfxABC'`, substitua com os seus valores. 

Agora é o momento de compilar, checar e instalar:

```
sudo make -j 16 && sudo make check -j 16
```
```
sudo make install -j 16
```

Para carregar a biblioteca e chamar o Gromacs:

```
source /home/patrick/gromacs/bin/GMXRC
```
```
gmx -version
```

>[!WARNING]
>
>Durante `sudo make check -j 16` ocorreram três erros por TIMEOUT. Prossegui e testei uma dinâmica simples e não houve nenhum erro.

*Boas dinâmicas!*

## 📜 Citação

- FAUSTINO, P. A. S. Tutorials: Compilando ROCm com HIPSyCL (AdaptiveCpp) no Ubuntu 22.04 para Gromacs 2024, 2024. README. Disponível em: <https://github.com/patrickallanfaustino/tutorials/blob/main/rocm-adaptivecpp-gromacs.md>. Acesso em: [dia] de [mês] de [ano].


## 📝 Licença

Esse projeto está sob licença. Veja o arquivo [LICENÇA](LICENSE.md) para mais detalhes.
