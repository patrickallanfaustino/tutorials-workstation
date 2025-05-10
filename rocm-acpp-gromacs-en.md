# Workflow Install Gromacs 2025.x with ROCm 6.3.3 and AdaptiveCpp 24.x in Ubuntu 24.04 Noble Numbat

![GitHub repo size](https://img.shields.io/github/repo-size/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub language count](https://img.shields.io/github/languages/count/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub forks](https://img.shields.io/github/forks/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub Release](https://img.shields.io/github/v/release/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub Tag](https://img.shields.io/github/v/tag/patrickallanfaustino/tutorials?style=for-the-badge)

<img src="picture_1.png" alt="computer">

> Tutorial to compile Gromacs 2025.1 with NNPOT-PyTorch support (Neural Networks), using AdaptiveCpp 24.10 as backend and ROCm 6.3.3 on Ubuntu 24.04 Kernel 6.11, to utilize AMD GPU acceleration on desktop

## 💻 Tested computer and prerequisites:
- CPU Ryzen 9 5900XT, Memória 2x16 GB DDR4, Chipset X570, GPU ASRock RX 6600 CLD 8 GB, dual boot with Windows 11 and Ubuntu 24.04 install in SSD's separated.

Before starting, ensure you meet the following requirements:

- You have a clean and updated installation of `Ubuntu 24.04` on your Linux machine.
- Your system is equipped with an `AMD RX6xxx RDNA2` series GPU (tested with `7xxx RDNA3` architectures).
- Documentation [ROCm 6.3.3](https://rocm.docs.amd.com/projects/install-on-linux/en/docs-6.3.3/index.html), [AdaptiveCpp 24.xx](https://github.com/AdaptiveCpp/AdaptiveCpp) and [Gromacs 2025.1](https://manual.gromacs.org/current/index.html).

You will also need to update your system and install the necessary packages:

```
sudo apt update && sudo apt upgrade
sudo apt autoremove && sudo apt autoclean
sudo apt install build-essential
```

Additionally, you will need to update and install packages on your machine:

```
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt update && sudo apt upgrade
```

Also, check the kernel version (version >= 6.8):
```
uname -r
```
Additionally, verify your default directory `$HOME`, as it serves as the primary path for most installations and configurations. Feel free to explore!

---
## 🔧 Install Timeshif

The [Timeshift](https://www.edivaldobrito.com.br/como-instalar-o-timeshift-no-ubuntu-linux-e-derivados/) is a software for creating backups. We recommend creating backups for each completed step. To install Timeshift, follow these steps:

```
sudo add-apt-repository ppa:teejee2008/timeshift
sudo apt update
sudo apt install timeshift
```

>[!TIP]
>
>Optionally, you can install [GRUB CUSTOMIZER](https://www.edivaldobrito.com.br/grub-customizer-no-ubuntu/) to manage the bootloader and [MAINLINE](https://www.edivaldobrito.com.br/como-instalar-o-ubuntu-mainline-kernel-installer-no-ubuntu-e-derivados/) to manage the installed kernel.
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
## 🔎 Install ROCm 6.3.3

It is recommended to perform all installations in the `Downloads` folder. We will install `rocm 6.3.3`.

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

To verify the installation, run:

```
groups
sudo clinfo
sudo rocminfo
sudo rocm-smi
```

> [!IMPORTANT]  
>When you run `rocminfo`, you should see the card name listed as `gfx1032` (for RX6600).
> 

You may need to install the library `rocm-llvm-dev`:
```
sudo apt install rocm-llvm-dev
```

The GPU should be recognized in the information. If it's not detected, try rebooting and checking again. The installation directory will be `/opt/rocm`.

>[!TIP]
>
>Use the command below to list all available `cases` in `amdgpu-install` that can be installed:
>
>```
>sudo amdgpu-install --list-usecase
>```
>
>To remove `amdgpu-install`, run:
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
## ⌚ Install LACT

The [LACT](https://github.com/ilya-zlobintsev/LACT) application allows you to control and overclock AMD, Intel, and Nvidia GPUs on Linux systems.

```
wget https://github.com/ilya-zlobintsev/LACT/releases/download/v0.7.3/lact-0.7.3-0.amd64.ubuntu-2404.deb
sudo dpkg -i lact-0.7.3-0.amd64.ubuntu-2404.deb
sudo systemctl enable --now lactd
```
**AMD Overclocking:** activate the function in LACT.

>[!WARNING]
>
>Download the [LACT](https://github.com/ilya-zlobintsev/LACT/releases/) package according to your Linux distribution.
>

---
## 🔨 Install AdaptiveCpp 24.xx

`AdaptiveCpp 24.xx` will work as a backend with `ROCm 6.3.3`. It is recommended to use the `Downloads` folder. To install:
```
sudo apt install -y libboost-all-dev git cmake
```
```
git clone https://github.com/AdaptiveCpp/AdaptiveCpp
cd AdaptiveCpp
sudo mkdir build && cd build
```

To compile with CMake (version >=3.28):
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

To verify the installation, `acpp-info` should display the GPU information:
```
acpp-info
```

>[!NOTE]
>
>**In my particular case**: Using `j$(nproc)`, sets the number of CPUs to use during compilation. You can omit this option if desired.
>

>[!WARNING]
>
>Be mindful of directory paths, such as /path/to/user/..., as incorrect paths often cause compilation errors.
>
---
## 💎 Install Gromacs 2025.x

**LIBTORCH!** It is possible to install the [libtorch](https://pytorch.org/) library to use Neural Networks. Check for the latest version. Use the `Downloads` folder.
```
wget https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-2.7.0%2Bcpu.zip
unzip libtorch-cxx11-abi-shared-with-deps-2.7.0%2Bcpu.zip
```

To edit the media, simply click on the edit icon in the upper right corner.
```
sudo apt install grace hwloc texlive
```

From now on, you can follow the official documentation. [instalattion guide](https://manual.gromacs.org/current/install-guide/index.html).
```
wget ftp://ftp.gromacs.org/gromacs/gromacs-2025.1.tar.gz
tar -xvfz gromacs-2025.1.tar.gz
cd gromacs-2025.1
sudo mkdir build && cd build
```
To compile with CMake (version >=3.28):
```
sudo cmake .. -DGMX_BUILD_OWN_FFTW=ON \
-DREGRESSIONTEST_DOWNLOAD=ON \
-DCMAKE_C_COMPILER=/opt/rocm/llvm/bin/clang \
-DCMAKE_CXX_COMPILER=/opt/rocm/llvm/bin/clang++ \
-DGMX_GPU=SYCL \
-DGMX_SYCL=ACPP \
-DCMAKE_INSTALL_PREFIX=$HOME/gromacs \
-DHIPSYCL_TARGETS='hip:gfx1032' \
-DGMX_HWLOC=ON \
-DGMX_USE_PLUMED=ON \
-DGMX_NNPOT=TORCH \
-DCMAKE_PREFIX_PATH="$HOME/Downloads/libtorch"
```

Note that I created a folder called `gromacs` for the compiled files and specified it with `-DCMAKE_INSTALL_PREFIX`, as this facilitates future updates of Gromacs.

>[!NOTE]
>
>**In my particular case**: Pay attention to `-DHIPSYCL_TARGETS='hip:gfxABC'`, replace with your values.
>

Now is the time to compile, check and install:
```
sudo make -j$(nproc)
sudo make check -j$(nproc)
sudo make install -j$(nproc)
```

To load the library and invoke Gromacs:
```
source /home/patrickfaustino/gromacs/bin/GMXRC
gmx -version
```

>[!WARNING]
>
>Timeout errors occurred during `sudo make check -j$(nproc)`. I continued and successfully tested a simple dynamics. It seems that Gromacs 2024/2025 users often encounter such issues, and adding `-DGMX_TEST_TIMEOUT_FACTOR=2` can provide more time for the tests.
>

>[!TIP]
>
>You can edit the file `/home/patrickfaustino/.bashrc` and add the code source `/home/patrickfaustino/gromacs/bin/GMXRC`. This way, every time you open the terminal, Gromacs will be loaded.
>

---
## 🐍 Install ANACONDA and PyTorch

The [Anaconda](https://www.anaconda.com/download) is an important package of Python libraries for scientific use. For installation:

```
wget https://repo.anaconda.com/archive/Anaconda3-2024.06-1-Linux-x86_64.sh
bash Anaconda3-2024.06-1-Linux-x86_64.sh
source ~/.bashrc
conda config --set auto_activate_base false
conda info
```
By running the above commands, the base conda environment will be automatically loaded into your shell prompt. If you want to disable this automatic loading, you can use: `conda config --set auto_activate_base false`.

>[!TIP]
>
>Download the latest [Anaconda](https://www.anaconda.com/download) package.
>

>[!WARNING]
>
>Make sure the installation will be in the path `$HOME/anaconda3` by confirming `yes` to all prompts. **DO NOT USE `sudo`**.
>

Now, let's create a virtual environment and install [Pytorch](https://pytorch.org/get-started/locally/). In the `$HOME` directory, create a `gromacs-nnpot` environment:
```
sudo apt install python3-venv libjpeg-dev python3-dev python3-pip
python3 -m venv gromacs-nnpot
source gromacs-nnpot/bin/activate
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.3
```
For check:
```
python3 -c 'import torch' 2> /dev/null && echo 'Success' || echo 'Failure'
python3 -c "import torch; print(torch.cuda.is_available())" 
python3 -c "import torch; print(torch.cuda.get_device_properties(0))"
python3 -c "import torch; x = torch.rand(5, 3); print(x)" 
```

>[!TIP]
>
>To uninstall a package, use `pip3 uninstall <package>`. To update a package, use `pip3 install --upgrade <package>`. To list installed packages, use `pip3 list`.
>

---
## 🧬 Install VMD

The [VMD](https://www.ks.uiuc.edu/Development/Download/download.cgi?PackageName=VMD) allows you to visualize molecules and perform analyses. For installation, we recommend the `Downloads` folder.

```
wget https://www.ks.uiuc.edu/Research/vmd/vmd-1.9.3/files/final/vmd-1.9.3.bin.LINUXAMD64-CUDA8-OptiX4-OSPRay111p1.opengl.tar.gz
tar xvzf vmd-1.9.3.bin.LINUXAMD64-CUDA8-OptiX4-OSPRay111p1.opengl.tar.gz
./configure
cd src
sudo make install -j$(nproc)
vmd
```

>[!TIP]
>
>Download the VMD package for you system distribuition.
>


### 🧪🧬⚗️ *Good molecular simulations!*

---
## 📜 Citation

- FAUSTINO, P. A. S. Tutorials: Workflow Install Gromacs 2025.x with ROCm 6.3.3 and AdaptiveCpp 24.x in Ubuntu 24.04 Noble Numbat, 2025. README. Available at: <[https://github.com/patrickallanfaustino/tutorials-workstation/blob/main/rocm-acpp-gromacs.md](https://github.com/patrickallanfaustino/tutorials-workstation/blob/main/rocm-acpp-gromacs-ptbr.md)>. Access at:xxx.
- Auxiliary source: [Install workflow with AMD GPU support (Framework 16, Ubuntu 24.04, GPU: AMD Radeon RX 7700S)](https://gromacs.bioexcel.eu/t/install-workflow-with-amd-gpu-support-framework-16-ubuntu-24-04-gpu-amd-radeon-rx-7700s/10870)

---
## 📝 License

This project is under a license. See the [LICENÇA](LICENSE.md) file for more details.
