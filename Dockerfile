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
        DOWNLOAD_URL=$(curl -s https://api.github.com/repos/MetaCubeX/mihomo/releases/latest | \
        jq -r '.assets[] | select(.name | contains("amd64")) | .browser_download_url'); \
        FILENAME="clash-linux-amd64.gz"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        DOWNLOAD_URL=$(curl -s https://api.github.com/repos/MetaCubeX/mihomo/releases/latest | \
        jq -r '.assets[] | select(.name | contains("arm64")) | .browser_download_url'); \
        FILENAME="clash-linux-arm64.gz"; \
    else \
        echo "Unsupported architecture: $TARGETARCH"; \
        exit 1; \
    fi && \
    curl -L -o "$FILENAME" "$DOWNLOAD_URL" && \
    chmod +x "$FILENAME" && \
    # 解压文件
    if [[ "$FILENAME" == *.gz ]]; then \
        gunzip "$FILENAME"; \
        mv "clash-linux-amd64" "clash"; \
    fi

# 启动脚本
CMD ["sh", "-c", "python ClashForge.py && python upload_gist.py"]
