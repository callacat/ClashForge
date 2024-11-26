# 使用最精简的 Python 镜像
FROM python:3.11-slim

# 设置工作目录
WORKDIR /app

# 安装时区数据包
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    curl \
    unzip \
    gzip \
    jq \
    && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖列表和执行文件到容器中
COPY requirements.txt .
COPY ClashForge.py .
COPY upload_gist.py .

# 安装依赖
RUN pip install --no-cache-dir -r requirements.txt \
    && rm -f requirements.txt \
    mkdir input

# 确定架构
ARG TARGETARCH
ENV TARGETARCH=${TARGETARCH:-amd64}


# 预下载并保存 clash 二进制文件
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        DOWNLOAD_URL="https://github.com/MetaCubeX/mihomo/releases/download/v1.18.10/mihomo-linux-amd64-compatible-v1.18.10.gz"; \
        FILENAME="clash-linux-amd64.gz"; \
        EXPECTED_BINARY_NAME="clash-linux-amd64"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        DOWNLOAD_URL="https://github.com/MetaCubeX/mihomo/releases/download/v1.18.10/mihomo-linux-arm64-v1.18.10.gz"; \
        FILENAME="clash-linux-arm64.gz"; \
        EXPECTED_BINARY_NAME="clash-linux-arm64"; \
    else \
        echo "Unsupported architecture: $TARGETARCH"; \
        exit 1; \
    fi && \
    curl -L -o "$FILENAME" "$DOWNLOAD_URL" && \
    chmod +x "$FILENAME" && \
    # 解压并重命名文件
    if [[ "$TARGETARCH" = "amd64" ]]; then \
        gunzip "$FILENAME" && mv "$EXPECTED_BINARY_NAME" "clash"; \
    else \
        gunzip "$FILENAME" && mv "$EXPECTED_BINARY_NAME" "clash"; \
    fi && \
    # 删除压缩包
    rm -f "$FILENAME"

# 启动脚本
CMD ["sh", "-c", "python ClashForge.py && python upload_gist.py"]
