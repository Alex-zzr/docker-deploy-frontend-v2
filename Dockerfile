FROM node:22-alpine AS build-stage
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .

RUN VITE_GRAPHQL_URI=__VITE_GRAPHQL_URI_PLACEHOLDER__ \
    VITE_SERVER_URI=__VITE_SERVER_URI_PLACEHOLDER__ \
    npm run build -- --mode production

FROM nginx:alpine AS production-stage
COPY nginx-custom.conf /etc/nginx/conf.d/default.conf
COPY --from=build-stage /app/dist /usr/share/nginx/html

COPY docker-entrypoint.sh /docker-entrypoint.sh

# 新增：安装dos2unix + 强制转LF换行（关键修复）
RUN apk add --no-cache dos2unix \
    && dos2unix /docker-entrypoint.sh \
    && chmod +x /docker-entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/docker-entrypoint.sh"]