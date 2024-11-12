# Compiling Gromacs 2024.x with ROCm and AdaptiveCpp/SyCL on Ubuntu 22.04

![GitHub repo size](https://img.shields.io/github/repo-size/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub language count](https://img.shields.io/github/languages/count/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub forks](https://img.shields.io/github/forks/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub Release](https://img.shields.io/github/v/release/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub Tag](https://img.shields.io/github/v/tag/patrickallanfaustino/tutorials?style=for-the-badge)

<img src="imagem1.png" alt="computer">

> Tutorial compile Gromacs 2024.x with AdaptiveCpp 24.06 in backend with ROCm 5.7.1 on Ubuntu 22.04, to use RDNA2 GPU acceleration on home desktop.

## 💻 Computer and Prerequisites:
- CPU Ryzen 7 2700X, Memory 2x16 GB DDR4, Chipset X470, GPU ASRock RX 6600 CLD 8 GB, dual boot Windows 11 and Ubuntu 22.04 installed on separate SSDs.

Before you begin, make sure you meet the following requirements:

- You have machine `Linux Ubuntu 22.04` updated.
- You have GPU family `AMD RX 6xxx RDNA2`. Not tested with other architectures.
- Documentations [ROCm 5.7.1](https://rocm.docs.amd.com/en/docs-5.7.1/), [AdaptiveCpp 24.06](https://github.com/AdaptiveCpp/AdaptiveCpp).

You will also need to update and install packages on your machine:

```
sudo apt update && sudo apt upgrade -y
```
```
sudo apt install cmake libboost-all-dev git build-essential libstdc++-12-dev libc++-16-dev libhwloc-dev hwloc grace
```
```
sudo apt autoremove && sudo apt autoclean
```
---
## 🔧 Install Kernel 5.15 generic

To install `Kernel 5.15 generic` on Ubuntu 22.04, follow these steps:

```
sudo apt install linux-image-generic
```

Add the extra Kernel headers and modules:

```
sudo apt install "linux-headers-$(uname -r)" "linux-modules-extra-$(uname -r)"
```

Next, and *in this order*, change to use Kernel 5.15 and remove the other installed Kernels. This task can be done with [GRUB CUSTOMIZER](https://www.edivaldobrito.com.br/grub-customizer-no-ubuntu/) or in the terminal. There is a lot of material on the internet to help with this task, here I only put the main objective, which is to install and use Kernel 5.15 on the machine.

>[!NOTE]
>
>**Personal case**: I rebooted and used GRUB to change the Kernel. Then `sudo dpkg -l | grep linux-image` to list the Kernels, `sudo apt remove` and `sudo apt autoremove && sudo apt autoclean` to remove the installed Kernels.

>[!TIP]
>
>For help identify the installed Kernel:
>
>```
>uname -r
>```
---
## 🪛 Install ROCm 5.7.1

Let's install `ROCm 5.7.1`. We need to give privileges to the user and add him to groups:

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

Download and install `ROCm 5.7.1` package:

```
https://repo.radeon.com/amdgpu-install/5.7.1/ubuntu/jammy/amdgpu-install_5.7.50701-1_all.deb
```
```
sudo apt install ./amdgpu-install_5.7.50701-1_all.deb
```

Using `amdgpu-install`, install the `rocm,hip,hiplibsdk` package:

```
sudo amdgpu-install --usecase=rocm,hip,hiplibsdk
```

Update all indexes and library links:

```
sudo ldconfig
```

Verify the installation, use:

```
sudo clinfo
```
```
sudo rocminfo
```

The GPU should be identified. If not, try `reboot` and check again. Installation will be in `PATH=/opt/rocm`.

>[!TIP]
>
>Use the command below to list all `cases` available in `amdgpu-install`:
>
>```
>sudo amdgpu-install --list-usecase
>```
>
>To remove `amdgpu-install`, use:
>
>```
>amdgpu-uninstall
>```
>```
>sudo apt purge amdgpu-install
>```
>
---
## 🔨 Install LLVM and libraries

`AdaptiveCpp` requires LLVM/Clang and some libraries. To install, do:

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
---
## 🪚 Install AdaptiveCpp 24.06

`AdaptiveCpp 24.06` will work in backend with `ROCm 5.7.1`. It contains `SyCL`. To install:

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
sudo cmake .. -DCMAKE_INSTALL_PREFIX=/home/patrick/sycl -DCMAKE_C_COMPILER=/opt/rocm/llvm/bin/clang -DCMAKE_CXX_COMPILER=/opt/rocm/llvm/bin/clang++ -DLLVM_DIR=/opt/rocm/llvm/lib/cmake/llvm/ -DROCM_PATH=/opt/rocm -DWITH_ROCM_BACKEND=ON -DWITH_SSCP_COMPILER=OFF -DWITH_OPENCL_BACKEND=OFF -DWITH_LEVEL_ZERO_BACKEND=OFF -DDEFAULT_TARGETS='hip:gfx1032'
```
```
sudo make install -j 16
```

>[!NOTE]
>
>**Personal case**: I recommend creating folders for compilations, so if something goes wrong you can just delete it and start over. I created the `sycl` folder with `sudo mkdir sycl` and indicated it with `-DCMAKE_INSTALL_PREFIX` when compiling. In `-DDEFAULT_TARGETS` complete `ABC` in `hip:gfx1ABC` with the information obtained in `clinfo` or `rocminfo`. This code corresponds to the physical address of the GPU. In `sudo make install -j 16`, the `-j 16` tag defines the number of CPUs (16) used in the compilation.

>[!WARNING]
>
>Attention to address paths, *i.e* `/path/to/user/...`, because they are the biggest cause of errors during compilations.
---
## 💎 Install Gromacs 2024.x

**OPTIONAL!** Before installing Gromacs, you may want to install some libraries that improve the performance and efficiency of calculations in Gromacs. *These libraries are optional because Gromacs already has BLAS and LAPACK built-in*. In the case below, you will install the `BLAS LAPACK 64bit` libraries in `/usr/lib/x86_64-linux-gnu/blas64/libblas64.so` and `/usr/lib/x86_64-linux-gnu/lapack64/liblapack64.so`.

```
sudo apt install liblapack64-dev libblas64-dev
```

**ROCBLAS and ROCSOLVER!** These are libraries optimized for AMD hardware. They are optional and also have `HIPBLAS HIPSOLVER`. They are installed with `amdgpu-install`.

From now on, you can follow the Gromacs [installation guide](https://manual.gromacs.org/current/install-guide/index.html) documentation. When compiling with CMake, use:

```
sudo cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON -DGMX_HWLOC=ON -DCMAKE_C_COMPILER=/opt/rocm/llvm/bin/clang -DCMAKE_CXX_COMPILER=/opt/rocm/llvm/bin/clang++ -DHIPSYCL_TARGETS='hip:gfx1032' -DGMX_GPU=SYCL -DGMX_SYCL=ACPP -DCMAKE_INSTALL_PREFIX=/home/patrick/gromacs -DCMAKE_PREFIX_PATH=/home/patrick/sycl -DSYCL_CXX_FLAGS_EXTRA=-DHIPSYCL_ALLOW_INSTANT_SUBMISSION=1 -DGMX_EXTERNAL_BLAS=on -DGMX_EXTERNAL_LAPACK=on -DGMX_BLAS_USER=/opt/rocm/rocblas/lib/librocblas.so -DGMX_LAPACK_USER=/opt/rocm/rocsolver/lib/librocsolver.so
```
Note that I created a folder called `gromacs` for the compiled files and indicated it with `-DCMAKE_INSTALL_PREFIX`.

>[!NOTE]
>
>**Personal case**: I used the `ROCBLAS` and `ROCSOLVER` libraries for the calculations, indicating with `-DGMX_EXTERNAL_BLAS=ON -DGMX_EXTERNAL_LAPACK=ON -DGMX_BLAS_USER= -DGMX_LAPACK_USER=`. If this is not your case, delete these tags. Pay attention to `-DHIPSYCL_TARGETS='hip:gfxABC'`, replace with your values.

Now it's time to compile, check and install:

```
sudo make -j 16 && sudo make check -j 16
```
```
sudo make install -j 16
```

Load the library and invoke Gromacs:

```
source /home/patrick/gromacs/bin/GMXRC
```
```
gmx -version
```

>[!WARNING]
>
>During `sudo make check -j 16` there were TIMEOUT errors. I went ahead and tested a simple dynamic and there were no problems. Apparently, more Gromacs 2024 users are facing these problems and with `-DGMX_TEST_TIMEOUT_FACTOR=2` you can give more time for the test.

>[!TIP]
>
>You can edit the `/home/patrick/.bashrc` file and add the code `source /home/patrick/gromacs/bin/GMXRC`. This way, every time you open the terminal, Gromacs will be loaded.

🧪🧬⚗️ *Good Molecular Dynamics*

---
## 📜 Citation

- FAUSTINO, P. A. S. Tutorials: Compiling Gromacs 2024.x with ROCm and AdaptiveCpp/SyCL on Ubuntu 22.04, 2024. README. Available in: <[https://github.com/patrickallanfaustino/tutorials/blob/main/rocm-adaptivecpp-gromacs.md](https://github.com/patrickallanfaustino/tutorials/blob/main/rocm-adaptivecpp-gromacs-en.md)>. Access in: [dia] de [mês] de [ano].

---
## 📝 License

This project is licensed under a license. See the [LICENSE](LICENSE.md) file for more details.
