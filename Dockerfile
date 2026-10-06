# ============================================================
# 基础镜像：ROS 官方 Humble 镜像（基于 Ubuntu 22.04）
# ============================================================
FROM ros:humble-ros-base

ENV DEBIAN_FRONTEND=noninteractive

# ============================================================
# 第 1 层：下载并解压 OpenVINO 2023.3 (避开 apt 源问题)
# ============================================================
RUN apt-get update && apt-get install -y --no-install-recommends wget tar && \
    wget -q https://storage.openvinotoolkit.org/repositories/openvino/packages/2023.3/linux/l_openvino_toolkit_ubuntu22_2023.3.0.13775.ceeafaf64f3_x86_64.tgz -O /tmp/openvino.tgz && \
    mkdir -p /opt/openvino_2023.3 && \
    tar -xzf /tmp/openvino.tgz -C /opt/openvino_2023.3 --strip-components=1 && \
    rm /tmp/openvino.tgz && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ============================================================
# 第 2 层：安装 CUDA 12.1 和 TensorRT 8.6.1
# ============================================================
RUN apt-get update && apt-get install -y --no-install-recommends wget gnupg && \
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        cuda-nvcc-12-1 cuda-cudart-dev-12-1 \
        libnvinfer8=8.6.1.6-1+cuda12.0 \
        libnvinfer-dev=8.6.1.6-1+cuda12.0 \
        libnvinfer-headers-dev=8.6.1.6-1+cuda12.0 \
        libnvinfer-plugin8=8.6.1.6-1+cuda12.0 \
        libnvinfer-plugin-dev=8.6.1.6-1+cuda12.0 \
        libnvinfer-headers-plugin-dev=8.6.1.6-1+cuda12.0 \
        libnvonnxparsers8=8.6.1.6-1+cuda12.0 \
        libnvonnxparsers-dev=8.6.1.6-1+cuda12.0 && \
    ln -sfn /usr/local/cuda-12.1 /usr/local/cuda && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ============================================================
# 第 3 层：安装编译工具
# ============================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3-colcon-common-extensions \
        python3-rosdep \
        ccache \
        build-essential \
        cmake && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN rosdep init || true && rosdep update

# ============================================================
# 第 4 层：设置环境变量
# ============================================================
ENV ROS_DISTRO=humble
ENV ROS_VERSION=2
ENV ROS_PYTHON_VERSION=3
ENV AMENT_PREFIX_PATH=/opt/ros/humble
ENV OpenVINO_DIR=/opt/openvino_2023.3/runtime/cmake
ENV InferenceEngine_DIR=/opt/openvino_2023.3/runtime/cmake
ENV ngraph_DIR=/opt/openvino_2023.3/runtime/cmake
ENV INTEL_OPENVINO_DIR=/opt/openvino_2023.3
ENV PKG_CONFIG_PATH=/opt/openvino_2023.3/runtime/lib/intel64/pkgconfig:/usr/local/lib/pkgconfig
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/opt/openvino_2023.3/runtime/lib/intel64:/usr/local/cuda-12.1/lib64:/opt/ros/humble/lib/x86_64-linux-gnu:/opt/ros/humble/lib
ENV PYTHONPATH=/opt/openvino_2023.3/python:/opt/openvino_2023.3/python/python3:/opt/ros/humble/lib/python3.10/site-packages:/opt/ros/humble/local/lib/python3.10/dist-packages
ENV PATH=/usr/local/cuda-12.1/bin:/opt/ros/humble/bin:$PATH
ENV TENSORRT_DIR=/usr
ENV CCACHE_DIR=/root/.ccache
ENV CCACHE_MAXSIZE=5G