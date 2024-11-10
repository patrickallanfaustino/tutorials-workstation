# Compilando ROCm com HIPSyCL (AdaptiveCpp) no Ubuntu 22.04 para Gromacs 2024

![GitHub repo size](https://img.shields.io/github/repo-size/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub language count](https://img.shields.io/github/languages/count/patrickallanfaustino/tutorials?style=for-the-badge)
![GitHub forks](https://img.shields.io/github/forks/patrickallanfaustino/tutorials?style=for-the-badge)
![Bitbucket open issues](https://img.shields.io/bitbucket/issues/patrickallanfaustino/tutorials?style=for-the-badge)
![Bitbucket open pull requests](https://img.shields.io/bitbucket/pr-raw/patrickallanfaustino/tutorials?style=for-the-badge)

<img src="imagem.png" alt="computer">

> Tutorial para compilar ROCm com HipSyCL (AdaptiveCpp) no Ubuntu 22.04, para utilizar GPUs Navi23 RDNA no Gromacs 2024.

## 💻 Pré-requisitos

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

<p align="justify">Em seguida e _nessa ordem_, altere para o Kernel 5.15 em uso e remova todos os demais Kernel instalados. Essa tarefa pode ser feita com o [GRUB CUSTOMIZER](https://www.edivaldobrito.com.br/grub-customizer-no-ubuntu/). Tem muito material na internet para auxiliar nessa etapa, aqui coloco apenas a tarefa principal que é instalar o Kernel 5.15 na máquina.</p>

>[!NOTE]
>
>**Meu Caso**: Com dual boot, então realizei um reboot e utilizei o GRUB para alterar o Kernel. Depois `sudo apt autoremove -y` e `sudo apt autoclean -y` para remover os outros Kernel instalados.

O comando abaixo ajudará a identificar o Kernel instalado:

```
uname -r
```


## ☕ Usando <nome_do_projeto>

Para usar <nome_do_projeto>, siga estas etapas:

```
<exemplo_de_uso>
```

Adicione comandos de execução e exemplos que você acha que os usuários acharão úteis. Forneça uma referência de opções para pontos de bônus!

## 📫 Contribuindo para <nome_do_projeto>

Para contribuir com <nome_do_projeto>, siga estas etapas:

1. Bifurque este repositório.
2. Crie um branch: `git checkout -b <nome_branch>`.
3. Faça suas alterações e confirme-as: `git commit -m '<mensagem_commit>'`
4. Envie para o branch original: `git push origin <nome_do_projeto> / <local>`
5. Crie a solicitação de pull.

Como alternativa, consulte a documentação do GitHub em [como criar uma solicitação pull](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request).

## 🤝 Colaboradores

Agradecemos às seguintes pessoas que contribuíram para este projeto:

<table>
  <tr>
    <td align="center">
      <a href="#" title="defina o título do link">
        <img src="https://avatars3.githubusercontent.com/u/31936044" width="100px;" alt="Foto do Iuri Silva no GitHub"/><br>
        <sub>
          <b>Iuri Silva</b>
        </sub>
      </a>
    </td>
    <td align="center">
      <a href="#" title="defina o título do link">
        <img src="https://s2.glbimg.com/FUcw2usZfSTL6yCCGj3L3v3SpJ8=/smart/e.glbimg.com/og/ed/f/original/2019/04/25/zuckerberg_podcast.jpg" width="100px;" alt="Foto do Mark Zuckerberg"/><br>
        <sub>
          <b>Mark Zuckerberg</b>
        </sub>
      </a>
    </td>
    <td align="center">
      <a href="#" title="defina o título do link">
        <img src="https://miro.medium.com/max/360/0*1SkS3mSorArvY9kS.jpg" width="100px;" alt="Foto do Steve Jobs"/><br>
        <sub>
          <b>Steve Jobs</b>
        </sub>
      </a>
    </td>
  </tr>
</table>

## 😄 Seja um dos contribuidores

Quer fazer parte desse projeto? Clique [AQUI](CONTRIBUTING.md) e leia como contribuir.

## 📝 Licença

Esse projeto está sob licença. Veja o arquivo [LICENÇA](LICENSE.md) para mais detalhes.
