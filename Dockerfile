# ------------------------------------------------------------------------------
# Install build tools and compile webstore/CHAOSgen components
FROM ubuntu:focal AS build
ADD . /sepulcher
RUN apt-get update && \
	apt-get install -y build-essential git ca-certificates \
	  libcurl4-gnutls-dev libgcrypt20-dev && \
	git clone https://github.com/Fullaxx/CHAOSgen.git CHAOSgen && \
	git clone https://github.com/Fullaxx/webstore.git webstore && \
	cd /CHAOSgen && ./compile.sh && \
	cd /webstore/src && ./compile_clients.sh && \
	cd /sepulcher/src && ./compile.sh

# ------------------------------------------------------------------------------
# Pull base image
FROM ubuntu:focal
MAINTAINER Brett Kuskie <fullaxx@gmail.com>

# ------------------------------------------------------------------------------
# Set environment variables
ENV DEBIAN_FRONTEND noninteractive

# ------------------------------------------------------------------------------
# Install openssl,libraries and clean up
RUN apt-get update && \
	apt-get install -y --no-install-recommends file nano openssl \
	  libcurl3-gnutls libgcrypt20 ca-certificates && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# ------------------------------------------------------------------------------
# Update .bashrc
RUN echo      >>/root/.bashrc && \
	echo "cd /data" >>/root/.bashrc

# ------------------------------------------------------------------------------
# Install CHAOSgen keygen, webstore client binaries, and sepulcher
COPY --from=build /CHAOSgen/keygen.exe /usr/bin/chaos_keygen.exe
COPY --from=build /webstore/src/ws_get.exe /webstore/src/ws_post.exe /usr/bin/
COPY --from=build /sepulcher/src/*.exe /usr/bin/
COPY scripts/*.sh /usr/bin/

# ------------------------------------------------------------------------------
# Add volumes
VOLUME /data

# ------------------------------------------------------------------------------
# Define default command
CMD ["/bin/bash"]
