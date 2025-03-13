# Use Ubuntu noble (24.04) as the base image
FROM ubuntu:noble

# Set environment variables
ENV container docker
ENV DEBIAN_FRONTEND=noninteractive
ENV PROOT_VERSION=5.4.0

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        systemd \
        systemd-sysv \
        sudo \
        openssh-server \
        curl \
        wget \
        iproute2 \
        net-tools \
        locales \
        xz-utils \
        bzip2 \
        adduser && \
    rm -rf /var/lib/apt/lists/*

# Configure systemd
RUN mkdir -p /run/systemd && \
    echo "root:password" | chpasswd  # Set root password (change later)

# Install PRoot (optional if you still need it)
RUN ARCH=$(uname -m) && \
    mkdir -p /usr/local/bin && \
    proot_url="https://github.com/ysdragon/proot-static/releases/download/v${PROOT_VERSION}/proot-${ARCH}-static" && \
    curl -Ls "$proot_url" -o /usr/local/bin/proot && \
    chmod 755 /usr/local/bin/proot

# Create a non-root user
RUN useradd -m -d /home/container -s /bin/bash container

# Set the working directory
WORKDIR /home/container

# Copy scripts into the container
COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
COPY --chown=container:container ./install.sh /install.sh
COPY --chown=container:container ./helper.sh /helper.sh
COPY --chown=container:container ./run.sh /run.sh

# Make the copied scripts executable
RUN chmod +x /entrypoint.sh /install.sh /helper.sh /run.sh

# Expose SSH port
EXPOSE 22

# Start systemd when the container runs
CMD ["/sbin/init"]
