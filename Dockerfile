FROM node:19 AS BUILD
WORKDIR /app
ADD package.json .
RUN npm install

FROM node:19-slim
COPY --from=build /app .
ADD . .
RUN apt-get update && apt-get install -y curl
HEALTHCHECK CMD curl --fail http://localhost:80 || exit 1
CMD ["node", "index.js"]
