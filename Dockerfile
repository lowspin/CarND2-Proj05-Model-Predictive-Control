# Dockerfile containing software for Control C++ quizzes
FROM ubuntu:xenial

WORKDIR /quizzes

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    gfortran \
    cmake \
    pkg-config \
    unzip \
    git \
    wget \
    cppad \
    python-matplotlib \ 
    python2.7-dev \
    libssl-dev \
    libuv1-dev     

RUN ./install_ipopt.sh Ipopt-3.12.7
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /src

COPY uWebSockets/ ./uWebSockets

RUN cd uWebSockets && \ 
    git checkout e94b6e1 && \ 
    mkdir build && \ 
    cd build && \
    cmake .. && \ 
    make && \ 
    make install && \
    ln -s /usr/lib64/libuWS.so /usr/lib/libuWS.so

WORKDIR /src/udacityterm2

