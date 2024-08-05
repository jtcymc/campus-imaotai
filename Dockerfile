FROM openjdk:8-jdk-alpine
LABEL maintainer="shaw123t@163.com"
# Install Nginx
# RUN apk update 
RUN apk update && apk add --no-cache nginx && mkdir -p /run/nginx && chmod 755 /run/nginx && mkdir -p /home/campus/conf
ADD ./campus-modular/target/campus-modular.jar /home/campus/app.jar
# 复制html文件到路径
COPY  ./vue_campus_admin/dist /usr/share/nginx/html
# 复制conf文件到路径
COPY ./conf/nginx.conf /etc/nginx/nginx.conf
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
