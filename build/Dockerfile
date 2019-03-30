FROM debian:9

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y install \
    openjdk-8-jdk \
    git-core \
    gnupg \
    flex \
    bison \
    build-essential \
    zlib1g-dev \
    gcc-multilib \
    libc6-dev-i386 \
    lib32ncurses5-dev \
    x11proto-core-dev \
    libx11-dev \
    lib32z-dev \
    ccache \
    libgl1-mesa-dev \
    xsltproc \
    unzip \
    g++-multilib \
    python-networkx \
    liblz4-tool \
    jq \
    gawk \
    gradle \
    bc \
    gperf \
    jq \
    fuseext2 \
    libxml2-dev \
    cutils \
    android-libcutils-dev \
    m4 \
    wget \
    locales \
    bsdmainutils \
    libxml2-utils \
    curl \
    zip \
    pxz \
    sudo \
    libssl-dev

RUN mkdir -p /opt/sdk \
    && cd /opt/sdk \
    && wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip -O sdk-tools.zip \
    && unzip sdk-tools.zip \
    && yes | ./tools/bin/sdkmanager --licenses \
    && ./tools/android update sdk -u --use-sdk-wrapper \
    && rm sdk-tools.zip

RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo && chmod a+x /usr/local/bin/repo

ENV PATH /opt/sdk/tools:/opt/sdk/tools/bin:${PATH}

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG='en_US.UTF-8'
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN useradd -G sudo debian --uid 1000 -s /bin/bash \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && mkdir /home/debian \
    && chown debian.debian /home/debian

USER debian
