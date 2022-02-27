FROM node:8.4.0-alpine
WORKDIR /pizza-express
COPY . .
EXPOSE 3000

RUN npm install 
RUN npm test 
CMD ["node","server.js"]
