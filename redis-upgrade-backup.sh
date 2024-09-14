#!/bin/bash

# 设置镜像和容器名称
REDIS_NAME="redis-server"        # Redis 容器名称
IMAGE_NAME="redis:7.4"           # 旧版镜像版本
NEW_IMAGE_NAME="redis:latest"    # 新版镜像版本
REDIS_DATADIR="/redisdatadir"    # 文件夹路径
DATA_REDIS="/redisdatadir/data"  # data路径
CONF_REDIS="/redisdatadir/conf"  # 配置文件路径
LOG_REDIS="/redisdatadir/logs"   # 日志路径
BACKUP_DIR_BASE="/redis_backup"  # 备份路径
BACKUP_DIR="$BACKUP_DIR_BASE/$(date +'%Y%m%d_%H%M%S')"

# 检查是否已经安装 Docker
if ! command -v docker &> /dev/null
then
    echo "Docker 未安装，请先安装 Docker。"
    exit 1
fi

# 函数：备份 Redis 数据
backup_redis_data() {
    echo "正在创建备份目录 $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    
    echo "停止 Redis 容器..."
    sudo docker stop $REDIS_NAME  # 使用 $REDIS_NAME 变量

    echo "正在备份 Redis 数据到 $BACKUP_DIR..."
    sudo cp -r "$DATA_REDIS" "$BACKUP_DIR"

    # 验证备份是否成功
    if [ $? -eq 0 ]; then
        echo "数据备份成功。备份存储在 $BACKUP_DIR。"
    else
        echo "数据备份失败，请检查权限和路径。"
        exit 1
    fi

    echo "重启 Redis 容器..."
    sudo docker start $REDIS_NAME  # 使用 $REDIS_NAME 变量

    echo "备份过程完成。"
}

# 函数：升级 Redis 镜像
upgrade_redis_image() {
    echo "正在拉取最新的 Redis 镜像..."
    sudo docker pull $NEW_IMAGE_NAME

    echo "删除旧的 Redis 容器..."
    sudo docker rm -f $REDIS_NAME  # 使用 $REDIS_NAME 变量

    echo "启动新的 Redis 容器..."
    sudo docker run -d --name $REDIS_NAME \
      -p 6379:6379 \
      -v "$DATA_REDIS:/data" \
      -v "$CONF_REDIS:/etc/redis" \
      -v "$LOG_REDIS:/var/log/redis" \
      $NEW_IMAGE_NAME

    # 验证容器是否启动成功
    if [ $? -eq 0 ]; then
        echo "Redis 容器升级成功并启动完成。"
    else
        echo "Redis 容器升级失败，请检查。"
        exit 1
    fi

    echo "显示容器状态："
    sudo docker ps
}

# 主程序入口
if [ "$1" == "backup" ]; then
    backup_redis_data
elif [ "$1" == "upgrade" ]; then
    upgrade_redis_image
else
    echo "在脚本后添加需要的运行的函数，升级：upgrade，备份：backup"
    exit 1
fi

