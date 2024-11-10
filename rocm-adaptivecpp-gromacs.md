# Compilando ROCm com HIPSyCL (AdaptiveCpp) no Ubuntu 22.04 para Gromacs 2024

![GitHub repo size](https://img.shields.io/github/repo-size/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub language count](https://img.shields.io/github/languages/count/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub forks](https://img.shields.io/github/forks/patrickallanfaustino/tutorials?style=for-the-badge)
![Bitbucket open issues](https://img.shields.io/bitbucket/issues/patrickallanfaustino/tutorials?style=for-the-badge)
![Bitbucket open pull requests](https://img.shields.io/bitbucket/pr-raw/patrickallanfaustino/tutorials?style=for-the-badge)

<img src="imagem.png" alt="computer">

> Tutorial para compilar ROCm 5.7.1 e HipSyCL (AdaptiveCpp 24.04) no Ubuntu 22.04 para utilizar GPUs Navi23 RDNA no Gromacs 2024.

## 💻 Computador testado e Pré-requisitos:
- CPU Ryzen 7 2700X, Memória 2x16 GB DDR4, Chipset X470, GPU ASRock RX 6600 CLD 8 GB, dual boot com Windows 11 e Ubuntu 22.04 instalados em SSD's separados.

Antes de começar, verifique se você atendeu aos seguintes requisitos:

- Você tem uma máquina `Linux Ubuntu 22.04` atualizado.
- Você tem uma GPU série `RX 6xxx RDNA 2`. Não testado com outras arquiteturas.
- Documentações [ROCm 5.7.1](https://rocm.docs.amd.com/en/docs-5.7.1/), [AdaptiveCpp 24.06](https://github.com/AdaptiveCpp/AdaptiveCpp).

Você também vai precisar atualizar e instalar os pacotes da sua máquina:

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

Adicione os headers e módulos extras do kernel:

```
sudo apt install "linux-headers-$(uname -r)" "linux-modules-extra-$(uname -r)"
```

Em seguida e *nessa ordem*, altere para usar o Kernel 5.15 e remova os demais Kernel instalados. Essa tarefa pode ser feita com o [GRUB CUSTOMIZER](https://www.edivaldobrito.com.br/grub-customizer-no-ubuntu/) ou no terminal. Existe vasto material na internet para auxiliar nessa tarefa, aqui coloco apenas o objetivo principal que é instalar e usar o Kernel 5.15 na máquina.

>[!NOTE]
>
>**Meu Caso**: Com dual boot, então realizei um reboot e utilizei o GRUB para alterar o Kernel. Depois `sudo apt autoremove -y` e `sudo apt autoclean -y` para remover os outros Kernel instalados.

>[!TIP]
>
>O comando abaixo ajudará a identificar o Kernel instalado:
>
>```
>uname -r
>```

## 🪛 Instalando ROCm 5.7.1

Vamos instalar o `ROCm versão 5.7.1`. Precisaremos dar previlégios ao usuário e adiciona-lo a grupos:

```
sudo usermod -a -G render,video $LOGNAME
echo ‘ADD_EXTRA_GROUPS=1’ | sudo tee -a /etc/adduser.conf
echo ‘EXTRA_GROUPS=video’ | sudo tee -a /etc/adduser.conf
echo ‘EXTRA_GROUPS=render’ | sudo tee -a /etc/adduser.conf
```

Download e instalação do pacote `ROCm 5.7.1`:

```
https://repo.radeon.com/amdgpu-install/5.7.1/ubuntu/jammy/amdgpu-install_5.7.50701-1_all.deb
sudo apt install ./amdgpu-install_5.7.50701-1_all.deb
```

Utilizando o `amdgpu-install`, instalar o pacote `rocm,hip,hiplibsdk`:

```
sudo amdgpu-install --usecase=rocm,hip,hiplibsdk
```

Atualizar todos os indices e links de bibliotecas:

```
sudo ldconfig
```

>[!TIP]
>
>Utilize o comando abaixo para listar todos os `cases` disponíveis para instalar com o `amdgpu-install`:
>
>```
>sudo amdgpu-install --list-usecase
>```

Para verificar a instalação, utilize:

```
sudo clinfo
```

```
sudo rocminfo
```

A GPU deverá ser identificada. Caso não consiga, experimente `reboot` e verifique novamente.

## 📝 Licença

Esse projeto está sob licença. Veja o arquivo [LICENÇA](LICENSE.md) para mais detalhes.
