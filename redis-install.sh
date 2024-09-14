#!/bin/bash

# 设置镜像和容器名称
IMAGE_NAME="redis:7.4"           # 镜像版本
DATA_REDIS="/redisdatadir/data"  # data路径
CONF_REDIS="/redisdatadir/conf"  # 配置文件路径
LOG_REDIS="/redisdatadir/logs"   # 日志路径

# 检查是否已经安装 Docker
if ! command -v docker &> /dev/null
then
    echo "Docker 未安装，请先安装 Docker。"
    exit 1
fi

# 检查目录是否存在，不存在则创建
if [ ! -d "$DATA_REDIS" ]; then
    echo "创建数据目录 $DATA_REDIS..."
    mkdir -p "$DATA_REDIS"
fi

if [ ! -d "$CONF_REDIS" ]; then
    echo "创建配置目录 $CONF_REDIS..."
    mkdir -p "$CONF_REDIS"
fi

if [ ! -d "$LOG_REDIS" ]; then
    echo "创建日志目录 $LOG_REDIS..."
    mkdir -p "$LOG_REDIS"
fi

# 设置权限
chmod -R 777 $DATA_REDIS $CONF_REDIS $LOG_REDIS

# 拉取最新的Redis镜像
echo "正在拉取最新的Redis镜像..."
sudo docker pull $IMAGE_NAME

# 启动一个临时 Redis 容器来获取配置文件
echo "启动临时 Redis 容器..."
sudo docker run -d --name temp-redis $IMAGE_NAME

# 将 Redis 默认配置文件复制到宿主机
echo "从容器复制 Redis 配置文件..."
sudo docker cp temp-redis:/usr/local/etc/redis $CONF_REDIS

# 停止并移除临时 Redis 容器
echo "移除临时 Redis 容器..."
sudo docker stop temp-redis && sudo docker rm temp-redis

# 运行正式的 Redis 容器并映射配置和日志目录
echo "正在运行 Redis 容器..."
sudo docker run -d --name docker-redis \
  -p 6379:6379 \
  -v "$DATA_REDIS:/data" \
  -v "$CONF_REDIS:/usr/local/etc/redis" \
  -v "$LOG_REDIS:/var/log/redis" \
  ${IMAGE_NAME} 

echo "Redis 容器启动完成。"

