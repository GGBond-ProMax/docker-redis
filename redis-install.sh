#!/bin/bash

# 设置镜像和容器名称
IMAGE_NAME="redis:7.4"
DATA_REDIS="/redisdatadir/data"

# 检查是否已经安装 Docker
if ! command -v docker &> /dev/null
then
    echo "Docker 未安装，请先安装 Docker。"
    exit 1
fi

# 检查 nginxdatadir 目录是否存在，不存在则创建
if [ ! -d "$DATA_REDIS" ]; then
    echo "创建目录 $DATA_REDIS..."
    mkdir -p "$DATA_REDIS"
fi

chmod -R 777 $DATA_REDIS

# 拉取最新的Redis镜像
echo "正在拉取最新的Redis镜像..."
sudo docker pull $IMAGE_NAME

# 运行Redis容器
echo "正在运行Redis容器..."
sudo docker run -d --name docker-redis \
  -p 6379:6379 \
  -v "$DATA_REDIS:/data" \
  ${IMAGE_NAME} \

echo "Redis容器启动完成。"
