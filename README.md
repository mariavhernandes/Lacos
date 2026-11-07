
| [Português 🇧🇷](README.md) | [English 🇺🇸](README-en.md) |
|---|---|

# Laços - Conexão e Interação Social

## 📌 Sobre o Projeto

O **Laços** é um projeto desenvolvido com o objetivo de incentivar a interação social e contribuir para a redução do isolamento social entre a terceira idade. A proposta consiste em oferecer uma plataforma digital acessível, que facilite a descoberta de atividades, a criação de vínculos e a comunicação entre pessoas com interesses em comum.

A aplicação permite que os usuários descubram locais e atividades de acordo com seus interesses, estabeleçam conexões, participem de grupos e conversem com outros usuários. Além disso, conta com funcionalidades destinadas aos responsáveis vinculados, possibilitando o acompanhamento de determinados recursos da aplicação.

O projeto também integra tecnologias de **Internet das Coisas (IoT)** e **Inteligência Artificial (IA)**, ampliando as possibilidades de interação e acompanhamento. O dispositivo IoT permite a captura de imagens por meio de uma câmera conectada a um microcontrolador ESP32-S3, enquanto o Assistente Laços utiliza inteligência artificial generativa para oferecer respostas e orientações aos usuários.

## 🚀 Funcionalidades

### 📱 Aplicativo

- **Cadastro e autenticação:** Criação de contas, login e recuperação de senha.
- **Gerenciamento de perfil:** Visualização e edição de informações pessoais.
- **Descoberta de atividades:** Sugestões de locais e atividades com base nos interesses dos usuários.
- **Interação social:** Conexões e conversas entre usuários.
- **Criação de grupos:** Formação de grupos para incentivar atividades e interações coletivas.
- **Notificações:** Acompanhamento de atualizações e interações na plataforma.
- **Vínculo com responsável:** Associação de uma conta de responsável ao usuário principal, permitindo o acesso a funcionalidades de acompanhamento.

### 📷 Internet das Coisas (IoT)

O módulo IoT é composto por um dispositivo físico desenvolvido com um microcontrolador **ESP32-S3** e uma câmera **OV2640**. Seu objetivo é realizar capturas de imagens por meio de um botão físico, permitindo que os registros sejam disponibilizados para consulta pelo responsável vinculado à conta.

Sua proposta foi pensada especialmente para situações de encontros presenciais, nas quais o usuário possa se sentir desconfortável ou em uma situação de risco e deseje compartilhar registros com seus familiares

Como proposta futura, foi idealizado um dispositivo compacto em formato de broche, inspirado na identidade visual do Laços, para facilitar seu uso no cotidiano.

<p align="center">
  <img width="400" alt="IoT Laços" src="https://github.com/user-attachments/assets/6fd38b62-71e6-4776-9c76-478a882e24f0" />
</p>

### 🤖 Inteligência Artificial (IA)

A inteligência artificial está integrada ao aplicativo por meio do **Assistente Laços**, um chatbot desenvolvido para oferecer suporte informativo e orientações aos usuários durante a utilização da plataforma.

O assistente utiliza a **API Gemini**, responsável pelo processamento das mensagens e pela geração de respostas em linguagem natural. Sua comunicação busca ser clara, acolhedora e acessível ao público-alvo.

<p align="center">
  <img width="180" alt="Chatbot 1" src="https://github.com/user-attachments/assets/5bdfa4b3-1d8d-4e2a-a18c-424973adf626" />
  <img width="180" alt="Chatbot 2" src="https://github.com/user-attachments/assets/c7163dfb-0866-473f-93a0-3f50527acc20" />
  <img width="180" alt="Chatbot 3" src="https://github.com/user-attachments/assets/eea76f46-dcaa-49c7-8614-3878900c9886" />
</p>

## 🏗️ Arquitetura e Metodologia

O desenvolvimento do Laços foi conduzido utilizando a abordagem **SDD (Spec-Driven Development)**.

O processo foi estruturado a partir da definição dos requisitos, elaboração das especificações, decomposição das funcionalidades em tarefas e implementação dos recursos planejados. Essa abordagem contribuiu para manter a organização do projeto, orientar as atividades da equipe e facilitar a validação das funcionalidades desenvolvidas.

A arquitetura do sistema contempla a integração de diferentes componentes:

- **Aplicativo mobile:** Desenvolvido em Flutter, responsável pelas interfaces, navegação e funcionalidades disponíveis aos usuários.
- **Camada de dados e autenticação:** Utiliza os serviços Firebase Authentication e Cloud Firestore para gerenciamento de contas e informações da aplicação.
- **Backend:** Desenvolvido em PHP, disponibiliza APIs responsáveis pelo recebimento e armazenamento das imagens do dispositivo IoT e pela comunicação com serviços externos.
- **Dispositivo IoT:** Composto pelo ESP32-S3 e pela câmera OV2640, responsável pela captura e transmissão das imagens ao backend.
- **Serviço de Inteligência Artificial:** Integrado ao backend por meio da API Gemini, responsável pelo processamento das mensagens e geração de respostas do Assistente Laços.
- **Infraestrutura:** Utiliza Docker para containerização e execução dos serviços de backend e dos ambientes de desenvolvimento.

A integração entre esses componentes permite que o aplicativo, o dispositivo físico e os serviços de inteligência artificial funcionem de maneira complementar, formando uma solução integrada.

## 🛠️ Tecnologias Utilizadas

| Tecnologia | Aplicação |
|---|---|
| **Flutter / Dart** | Desenvolvimento do aplicativo mobile |
| **Firebase Authentication** | Autenticação e gerenciamento de usuários |
| **Cloud Firestore** | Armazenamento e gerenciamento de dados |
| **PHP** | Desenvolvimento do backend e das APIs |
| **Docker** | Containerização e gerenciamento dos serviços |
| **Gemini API** | Processamento de mensagens e geração de respostas por IA |
| **C/C++ (Arduino)** | Desenvolvimento do firmware do dispositivo |
| **HTTP / REST API** | Comunicação e integração entre os componentes |

## 📸 Capturas de Tela

### 👴🏻 Sistema Idoso

<p align="left">
  <img width="180" alt="Login" src="https://github.com/user-attachments/assets/bc56bf2b-52ed-40d1-aae0-0141f4a6ece3" />
  <img width="180" alt="Entrada" src="https://github.com/user-attachments/assets/5dfe058a-d840-4a25-9cd4-2ed47b1f6503" />
  <img width="180" alt="Inicial" src="https://github.com/user-attachments/assets/438ad2c2-5264-4bc2-a741-46ad34566a96" />
  <img width="180" alt="Lugares" src="https://github.com/user-attachments/assets/3edac756-5952-4f20-a806-0022c8d8d489" />
</p>

### 👩🏻 Sistema Familiar

<p align="left">
  <img width="180" alt="Inicial Familiar" src="https://github.com/user-attachments/assets/0c12e1cd-1de3-4b1c-b4e7-1d22915730da" />
  <img width="180" alt="Registro Iot" src="https://github.com/user-attachments/assets/7982f901-cd26-45fd-a108-1cf5680dfbca" />
  <img width="180" alt="Conversas" src="https://github.com/user-attachments/assets/210fec7b-f77d-42b4-9664-e1dcb36521ee" />
</p>

