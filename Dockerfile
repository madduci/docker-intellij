FROM ubuntu:22.04 as build

ARG VERSION=2023.1.3
ENV INTELLIJ_URL="https://download.jetbrains.com/idea/ideaIC-${VERSION}.tar.gz"

RUN echo "Installing curl" \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        curl \
        wget \
    && echo "Downloading IntelliJ" \
    && curl -o /tmp/intellij.tar.gz -L "${INTELLIJ_URL}" \
    && tar -xzf /tmp/intellij.tar.gz -C /opt/ \
    && mv /opt/idea* /opt/intellij \
    && chmod +x /opt/intellij/bin/*.sh \
    && echo "Performing cleanup" \
    && rm -rf /tmp/*

# Installing programming Fonts
RUN curl -L https://github.com/hbin/top-programming-fonts/raw/master/install.sh | bash
    
FROM ubuntu:22.04

LABEL description="Docker Image with IntelliJ Community Edition" \
      maintainer="Michele Adduci <adduci@tutanota.com>" \
      license="MIT"

ARG USERNAME=user

ENV USER=${USERNAME} \
    USER_HOME=/home/${USERNAME} \
    TZ=Europe/Berlin 

RUN echo "Creating non-root user: ${USER}" \
    && mkdir -p ${USER_HOME} \
    && useradd --system -d ${USER_HOME} --shell /bin/bash --uid 1000 --gid root ${USER} \
    && chown -R ${USER} ${USER_HOME} \
    && chown ${USER} -R ${USER_HOME} \
    && echo "Setting password for ${USER}" \
    && echo "${USER}:${USER}" | chpasswd 
    
COPY --chown=${USER}:root --from=build /opt/intellij /opt/intellij
COPY --chown=${USER}:root --from=build /root/.fonts /home/${USER}/.fonts

RUN echo "Installing required tools and libraries" \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        curl \
        git \
        xvfb \
        sudo \
        libxtst6 \
        libfontconfig1 \
        libxrender1 \
        libxslt1.1 \
        libxml2 \
        libgtk2.0 \
        libasound2 \  
        fonts-liberation \
    && echo "Setting timezone to $TZ" \
    && echo $TZ > /etc/timezone \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo "Setting sudo permissions (passwordless) for ${USER}" \
    && echo "${USER} ALL=(ALL) NOPASSWD:SETENV: ALL" >> /etc/sudoers.d/${USER} \
    && echo "Performing cleanup" \
    && apt-get -q clean -y \
    && apt-get autoclean \
    && rm -rf /var/cache/* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

USER ${USER}

RUN echo "Creating .config/JetBrains folder" \
    && mkdir -p ~/.config/JetBrains

ENTRYPOINT [ "/opt/intellij/bin/idea.sh" ]
