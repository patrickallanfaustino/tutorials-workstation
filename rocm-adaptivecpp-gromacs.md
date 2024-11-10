# Compilando ROCm com HIPSyCL (AdaptiveCpp) no Ubuntu 22.04 para Gromacs 2024

![GitHub repo size](https://img.shields.io/github/repo-size/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub language count](https://img.shields.io/github/languages/count/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub forks](https://img.shields.io/github/forks/patrickallanfaustino/tutorials?style=for-the-badge)
![Bitbucket open issues](https://img.shields.io/bitbucket/issues/patrickallanfaustino/tutorials?style=for-the-badge)
![Bitbucket open pull requests](https://img.shields.io/bitbucket/pr-raw/patrickallanfaustino/tutorials?style=for-the-badge)

<img src="imagem.png" alt="computer">

> Tutorial para compilar ROCm 5.7.1 e HipSyCL (AdaptiveCpp 24.04) no Ubuntu 22.04 para utilizar GPUs Navi23 RDNA no Gromacs 2024.

## 💻 Computador testado:
- CPU Ryzen 7 2700X, Memória 2x16 GB DDR4, Chipset X470, GPU ASRock RX 6600 CLD 8 GB, dual boot com Windows 11 e Ubuntu 22.04 instalados em SSD's separados.

## ⚙️ Pré-requisitos

Antes de começar, verifique se você atendeu aos seguintes requisitos:

- Você tem uma máquina `Linux Ubuntu 22.04` atualizado.
- Você tem uma GPU série `RX 6xxx RDNA 2`. Não testado com outras arquiteturas.
- Documentações [ROCm 5.7.1](https://rocm.docs.amd.com/en/docs-5.7.1/), [AdaptiveCpp 24.06](https://github.com/AdaptiveCpp/AdaptiveCpp).

## 🔧 Instalando Kernel 5.15 generic

Para instalar o `Kernel 5.15 generic` no Ubuntu 22.04, siga estas etapas:

```
sudo apt install linux-image-generic
```

Adicione os headers e módulos extras do kernel:

```
sudo apt install "linux-headers-$(uname -r)" "linux-modules-extra-$(uname -r)"
```

Em seguida e _nessa ordem_, altere para o Kernel 5.15 em uso e remova todos os demais Kernel instalados. Essa tarefa pode ser feita com o [GRUB CUSTOMIZER](https://www.edivaldobrito.com.br/grub-customizer-no-ubuntu/). Tem muito material na internet para auxiliar nessa etapa, aqui coloco apenas a tarefa principal que é instalar o Kernel 5.15 na máquina.

>[!NOTE]
>
>**Meu Caso**: Com dual boot, então realizei um reboot e utilizei o GRUB para alterar o Kernel. Depois `sudo apt autoremove -y` e `sudo apt autoclean -y` para remover os outros Kernel instalados.

O comando abaixo ajudará a identificar o Kernel instalado:

```
uname -r
```

Working...

## 📝 Licença

Esse projeto está sob licença. Veja o arquivo [LICENÇA](LICENSE.md) para mais detalhes.
