# 构建阶段：统一阶段名，使用 Node 20 兼容 Vite 7 + TypeScript
FROM node:20-alpine AS build-stage
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .

# 使用项目内置的生产环境构建脚本，规避参数传递错误
RUN npm run build:prod

# 生产阶段
FROM nginx:alpine AS production-stage
COPY nginx-custom.conf /etc/nginx/conf.d/default.conf
COPY --from=build-stage /app/dist /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]