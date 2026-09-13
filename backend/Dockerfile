# Imagem base leve do Node.js (ou troque por python:3.11-slim se for usar Python para a IA)
FROM node:18-alpine

# Define o diretório de trabalho dentro do container
WORKDIR /usr/src/app

# Copia arquivos de dependências
COPY package*.json ./

# Instala as dependências (quando você tiver um package.json)
# RUN npm install

# Copia o restante do código da pasta backend
COPY . .

# Porta exposta do backend
EXPOSE 3000

# Comando para rodar a aplicação
CMD ["npm", "start"]