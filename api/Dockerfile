FROM node:14-alpine As development

WORKDIR /usr/src/app

COPY ./api ./api
COPY ./models ./models
COPY ./package*.json ./

RUN npm install --no-rollback

WORKDIR /usr/src/app/api

RUN npm install
RUN npm run build

FROM node:14-alpine As production

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install --only=production

COPY . .

COPY --from=development /usr/src/app/api/dist ./dist

CMD ["node", "dist/main"]