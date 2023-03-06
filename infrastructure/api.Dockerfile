FROM node:18-alpine AS build
WORKDIR /usr/src/app
COPY ./api ./api
COPY ./models ./models
COPY ./package*.json ./

RUN apk update
RUN apk add --no-cache --virtual build-dependencies g++ make py3-pip libzmq zeromq-dev zeromq 
RUN npm set progress=false \
    && npm config set fetch-retry-mintimeout 6000000 \
    && npm config set fetch-retry-maxtimeout 6000000 
ENV NODE_ENV development

# Install packages
RUN npm ci --omit=dev --no-audit
RUN cp -R ./node_modules ./prod_node_modules
RUN cp -R ./api/node_modules ./api/prod_node_modules
RUN npm install --no-audit

# Build
WORKDIR /usr/src/app/api
RUN npm run build
RUN apk del build-dependencies

FROM node:18-alpine AS production

# Copy the bundled code from the build stage to the production image
COPY --from=build --chown=node:node  /usr/src/app/prod_node_modules /usr/src/app/node_modules
COPY --from=build --chown=node:node  /usr/src/app/api/prod_node_modules /usr/src/app/api/node_modules
COPY --from=build --chown=node:node  /usr/src/app/api/dist /usr/src/app/api/dist
COPY --from=build --chown=node:node  /usr/src/app/models/ts /usr/src/app/models/ts

WORKDIR /usr/src/app/api

USER node
CMD ["node", "dist/main"]

FROM node:18-alpine AS development
COPY --from=build /usr/src/app/ /usr/src/app
WORKDIR /usr/src/app/api
CMD ["npm", "run", "start:dev"]
