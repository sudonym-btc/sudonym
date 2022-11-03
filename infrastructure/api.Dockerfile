FROM node:18-alpine As development

WORKDIR /usr/src/app

COPY ./api ./api
COPY ./models ./models
COPY ./package*.json ./

RUN apk update
RUN apk add --no-cache --virtual build-dependencies g++ make py3-pip 
RUN npm config set fetch-retry-mintimeout 100000
RUN npm config set fetch-retry-maxtimeout 6000000
RUN npm install --unsafe-perm
RUN apk del build-dependencies

WORKDIR /usr/src/app/api
RUN npm run build

CMD ["node", "dist/main"]