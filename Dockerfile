FROM ubuntu:18.04

COPY . /tmp

RUN cat /tmp/aliyun.list > /etc/apt/sources.list


RUN apt-get update && apt-get install -y --no-install-recommends \
        qt4-default \
    && apt-get update && apt-get install -y --no-install-recommends \
        libfreetype6 ruby libdevil1c2  \
        libboost-regex1.65.1 libboost-system1.65.1 libboost-thread1.65.1 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ARG RCSSSERVER3D_RELEASE=0.7.2



RUN buildDeps='g++ cmake git autogen automake libtool libfreetype6-dev libsdl1.2-dev ruby-dev libdevil-dev libboost-dev libboost-thread-dev libboost-regex-dev libboost-system-dev libqt4-opengl-dev'; \
    apt-get update && apt-get install -y --no-install-recommends $buildDeps libtbb-dev \
    && cd /tmp/ode-tbb \
    && ./autogen.sh \
    && ./configure --enable-shared --disable-demos \
        --enable-double-precision --disable-asserts --enable-malloc \
    && make -j \
    && make install \
    && ldconfig \
    && rm -rf /tmp/ode-tbb \
    && mkdir -p /tmp/SimSpark/spark/build && cd /tmp/SimSpark/spark/build && cmake .. && make -j$(nproc) && make install && ldconfig \
    && mkdir -p /tmp/SimSpark/rcssserver3d/build && cd /tmp/SimSpark/rcssserver3d/build && cmake -DRVDRAW=ON .. && make -j$(nproc) && make install && ldconfig \
    && rm -rf /tmp/SimSpark \
    && apt-get purge -y --auto-remove $buildDeps && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH=/usr/local/lib/simspark:/usr/local/lib/rcssserver3d


ENTRYPOINT ["rcssserver3d"]

