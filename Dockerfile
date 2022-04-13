FROM ubuntu:20.04

MAINTAINER Sebastien Macke <lanjelot@gmail.com>

ENV DEBIAN_FRONTEND=noninteractive 

RUN apt-get update \
  && apt-get install -y \
    build-essential python3-setuptools \
    libcurl4-openssl-dev python3-dev libssl-dev \
    ldap-utils \
    libmariadbclient-dev \
    libpq-dev \
    ike-scan unzip default-jdk \
    libsqlite3-dev libsqlcipher-dev \
    python3-pip \
  && rm -rf /var/lib/apt/lists/*

# xfreerdp (see https://github.com/FreeRDP/FreeRDP/wiki/Compilation)
RUN apt-get update && apt-get install -y ninja-build build-essential git-core debhelper cdbs dpkg-dev autotools-dev cmake pkg-config xmlto libssl-dev docbook-xsl xsltproc libxkbfile-dev libx11-dev libwayland-dev libxrandr-dev libxi-dev libxrender-dev libxext-dev libxinerama-dev libxfixes-dev libxcursor-dev libxv-dev libxdamage-dev libxtst-dev libcups2-dev libpcsclite-dev libasound2-dev libpulse-dev libjpeg-dev libgsm1-dev libusb-1.0-0-dev libudev-dev libdbus-glib-1-dev uuid-dev libxml2-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libfaad-dev libfaac-dev \
 && apt-get install -y libavutil-dev libavcodec-dev libavresample-dev \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /opt/FreeRDP
RUN git clone https://github.com/FreeRDP/FreeRDP/ .
RUN cmake -DCMAKE_BUILD_TYPE=Debug -DWITH_SSE2=ON . && cmake --build . && cmake --build . --target install

WORKDIR /opt/patator
COPY ./requirements.txt ./
RUN python3 -m pip install --upgrade pip \
  && python3 -m pip install -r requirements.txt

# utils
RUN apt-get update && apt-get install -y ipython3 iputils-ping iproute2 netcat curl rsh-client telnet vim mlocate nmap xauth xorg openbox \
  && rm -rf /var/lib/apt/lists/*
RUN echo 'set bg=dark' > /root/.vimrc

RUN groupadd -g 1000 testus
RUN useradd -d /home/testus -s /bin/bash -m testus -u 1000 -g 1000
USER testus
ENV HOME /home/testus 

COPY ./patator.py ./
ENTRYPOINT ["python3", "./patator.py"]
