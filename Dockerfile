# 使用官方的Java运行时作为父镜像
FROM openjdk:8-jdk-alpine AS backend-builder
# 设置工作目录为/app
WORKDIR /app
# 运行mvn命令来下载依赖
RUN mvn dependency:go-offline
# 复制所有文件到容器
COPY ./ .
# 编译并打包Java应用
RUN mvn package -DskipTests

# 使用官方的Node.js运行时作为父镜像构建前端
FROM node:16 AS frontend-builder

# 设置工作目录为/app/frontend
WORKDIR /app/frontend

# 复制Vue项目的所有文件到容器
COPY ./vue_campus_admin .

# 安装依赖并构建Vue应用
RUN npm install && npm run build
FROM openjdk:8-jdk-alpine
LABEL maintainer="shaw123t@163.com"
# Install Nginx
# RUN apk update
RUN apk update && apk add --no-cache nginx && mkdir -p /run/nginx && chmod 755 /run/nginx && mkdir -p /home/campus/conf
COPY  --from=backend-builder /app/campus-modular/target/campus-modular.jar /home/campus/app.jar
# 复制html文件到路径
COPY  --from=frontend-builder /app/frontend/dist /usr/share/nginx/html
# 复制conf文件到路径
COPY  ./conf/nginx.conf /etc/nginx/nginx.conf
# 配置Nginx反向代理到后端服务
# 这一步在nginx.conf中完成
# 暴露Nginx默认端口
EXPOSE 80
# 后端服务
ENV SERVER_PORT=8160
EXPOSE ${SERVER_PORT}
# Set memory limits for the Java application
ENV JAVA_OPTS="-Xms128m -Xmx256m"
CMD ["sh", "-c", "java ${JAVA_OPTS} -Djava.security.egd=file:/dev/./urandom -Dserver.port=${SERVER_PORT} -jar /home/campus/app.jar & nginx -g 'daemon off;'"]
