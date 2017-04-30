FROM oskarirauta/alpine:latest
MAINTAINER Oskari Rauta <oskari.rauta@gmail.com>

# Environment variables
ENV LOCAL_NETWORK
ENV OPENVPN_USERNAME=**None**
ENV OPENVPN_PASSWORD=**None**
ENV OPENVPN_PROVIDER=**None**
ENV OPENVPN_CONFIG=**None**
ENV PUID=1001
ENV PGID=2001
ENV PYTHON_EGG_CACHE="/config/plugins/.python-eggs"

# Volumes
VOLUME /config
VOLUME /data
VOLUME /etc/openvpn

# Exposed ports
EXPOSE 8112 58846 58946 58946/udp

# Install runtime packages
RUN \
 apk add --no-cache \
	ca-certificates \
	p7zip \
	unrar \
	unzip \
	shadow \
	curl \
	openssl \
	jq \
	tar \
	transmission-cli \
	transmission-daemon

# install openvpn
RUN apk add --no-cache openvpn
 
# cleanup
RUN rm -rf /root/.cache

# Create user and group
RUN addgroup -S -g 2001 media
RUN adduser -SH -u 1001 -G media -s /sbin/nologin -h /config transmission

# add local files and replace init script
RUN rm /etc/init.d/openvpn
COPY openvpn/ /etc/openvpn/
COPY init/ /etc/init.d/

RUN chmod +x /etc/init.d/openvpn
#\
# && chmod +x /etc/init.d/deluged \
# && chmod +x /etc/init.d/deluge-web

RUN chmod +x /etc/openvpn/transmission-up.sh \
 && chmod +x /etc/openvpn/transmission-down.sh

#RUN rc-update add openvpn default
