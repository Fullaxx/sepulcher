# ------------------------------------------------------------------------------
# Install build tools and compile webstore
FROM ubuntu:focal AS build
RUN apt-get update && \
	apt-get install -y build-essential git ca-certificates \
	  libcurl4-gnutls-dev libgcrypt20-dev && \
	git clone https://github.com/Fullaxx/webstore.git webstore && \
	cd webstore/src && \
	./compile_clients.sh

# ------------------------------------------------------------------------------
# Pull base image
FROM ubuntu:focal
MAINTAINER Brett Kuskie <fullaxx@gmail.com>

# ------------------------------------------------------------------------------
# Set environment variables
ENV DEBIAN_FRONTEND noninteractive

# ------------------------------------------------------------------------------
# Install gnupg2,libraries and clean up
RUN apt-get update && \
	apt-get install -y --no-install-recommends file nano \
	  gnupg2 libcurl3-gnutls libgcrypt20 ca-certificates && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# ------------------------------------------------------------------------------
# Prevent warnings about bad dir permissions
RUN echo >>/root/.bashrc && \
	echo "chmod 0700 /root/.gnupg" >>/root/.bashrc

# ------------------------------------------------------------------------------
# Install webstore client binaries
COPY --from=build /webstore/src/ws_get.exe /webstore/src/ws_post.exe /usr/bin/

# ------------------------------------------------------------------------------
# Add volumes
VOLUME /root/.gnupg
VOLUME /root/xfer

# ------------------------------------------------------------------------------
# Define default command
CMD ["/bin/bash"]
