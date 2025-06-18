FROM ubuntu:24.04

ENV TIMEZONE=America/New_York \
    DEBIAN_FRONTEND=noninteractive \
    WINEPREFIX=/wine \
    WINEARCH=win64

# Install system packages
RUN apt-get update && \
    apt-get install -y \
        python3-pip \
        python3-venv \
        software-properties-common \
        supervisor \
        unzip \
        curl \
        xvfb \
        wget \
        rsync \
        net-tools \
        ca-certificates \
        gnupg \
        lsb-release && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add Wine repository and install Wine
RUN dpkg --add-architecture i386 && \
    mkdir -pm755 /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/$(lsb_release -cs)/winehq-$(lsb_release -cs).sources && \
    apt-get update && \
    apt-get install -y --install-recommends winehq-stable && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Python packages (try system packages first, fallback to pip)
RUN apt-get update && \
    (apt-get install -y python3-valve || pip3 install --no-cache-dir --break-system-packages python-valve) && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install winetricks
RUN wget -q https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /usr/bin/winetricks && \
    chmod +x /usr/bin/winetricks

# Install additional packages for VNC and debugging
RUN apt-get update && \
    apt-get install -y x11vnc strace cabextract && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . ./

RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
    && echo $TIMEZONE > /etc/timezone \
    && chmod +x /entrypoint.sh \
    && cd /usr/bin/ \
    && chmod +x astroneer_controller steamcmd_setup

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD supervisorctl status || exit 1

EXPOSE 8777

VOLUME ["/astroneer"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord"]