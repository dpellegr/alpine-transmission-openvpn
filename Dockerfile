FROM oskarirauta/alpine:latest
MAINTAINER Oskari Rauta <oskari.rauta@gmail.com>

# Environment variables
ENV LOCAL_NETWORK=
ENV OPENVPN_USERNAME=**None**
ENV OPENVPN_PASSWORD=**None**
ENV OPENVPN_PROVIDER=**None**
ENV OPENVPN_CONFIG=**None**
ENV PUID=1001
ENV PGID=2001
ENV TRANSMISSION_ALT_SPEED_DOWN=50
ENV TRANSMISSION_ALT_SPEED_ENABLED=false"
ENV TRANSMISSION_ALT_SPEED_TIME_BEGIN=540"
ENV TRANSMISSION_ALT_SPEED_TIME_DAY=127"
ENV TRANSMISSION_ALT_SPEED_TIME_ENABLED=false"
ENV TRANSMISSION_ALT_SPEED_TIME_END=1020"
ENV TRANSMISSION_ALT_SPEED_UP=50"
ENV TRANSMISSION_BIND_ADDRESS_IPV4=0.0.0.0"
ENV TRANSMISSION_BIND_ADDRESS_IPV6=::"
ENV TRANSMISSION_BLOCKLIST_ENABLED=false"
ENV TRANSMISSION_BLOCKLIST_URL=http://www.example.com/blocklist"
ENV TRANSMISSION_CACHE_SIZE_MB=4"
ENV TRANSMISSION_DHT_ENABLED=true"
ENV TRANSMISSION_DOWNLOAD_DIR=/data/completed"
ENV TRANSMISSION_DOWNLOAD_LIMIT=100"
ENV TRANSMISSION_DOWNLOAD_LIMIT_ENABLED=0"
ENV TRANSMISSION_DOWNLOAD_QUEUE_ENABLED=true"
ENV TRANSMISSION_DOWNLOAD_QUEUE_SIZE=5"
ENV TRANSMISSION_ENCRYPTION=1"
ENV TRANSMISSION_IDLE_SEEDING_LIMIT=30"
ENV TRANSMISSION_IDLE_SEEDING_LIMIT_ENABLED=false"
ENV TRANSMISSION_INCOMPLETE_DIR=/data/incomplete"
ENV TRANSMISSION_INCOMPLETE_DIR_ENABLED=true"
ENV TRANSMISSION_LPD_ENABLED=false"
ENV TRANSMISSION_MAX_PEERS_GLOBAL=200"
ENV TRANSMISSION_MESSAGE_LEVEL=2"
ENV TRANSMISSION_PEER_CONGESTION_ALGORITHM="
ENV TRANSMISSION_PEER_ID_TTL_HOURS=6"
ENV TRANSMISSION_PEER_LIMIT_GLOBAL=200"
ENV TRANSMISSION_PEER_LIMIT_PER_TORRENT=50"
ENV TRANSMISSION_PEER_PORT=51413"
ENV TRANSMISSION_PEER_PORT_RANDOM_HIGH=65535"
ENV TRANSMISSION_PEER_PORT_RANDOM_LOW=49152"
ENV TRANSMISSION_PEER_PORT_RANDOM_ON_START=false"
ENV TRANSMISSION_PEER_SOCKET_TOS=default"
ENV TRANSMISSION_PEX_ENABLED=true"
ENV TRANSMISSION_PORT_FORWARDING_ENABLED=false"
ENV TRANSMISSION_PREALLOCATION=1"
ENV TRANSMISSION_PREFETCH_ENABLED=1"
ENV TRANSMISSION_QUEUE_STALLED_ENABLED=true"
ENV TRANSMISSION_QUEUE_STALLED_MINUTES=30"
ENV TRANSMISSION_RATIO_LIMIT=2"
ENV TRANSMISSION_RATIO_LIMIT_ENABLED=false"
ENV TRANSMISSION_RENAME_PARTIAL_FILES=true"
ENV TRANSMISSION_RPC_AUTHENTICATION_REQUIRED=false"
ENV TRANSMISSION_RPC_BIND_ADDRESS=0.0.0.0"
ENV TRANSMISSION_RPC_ENABLED=true"
ENV TRANSMISSION_RPC_PASSWORD=password"
ENV TRANSMISSION_RPC_PORT=9091"
ENV TRANSMISSION_RPC_URL=/transmission/"
ENV TRANSMISSION_RPC_USERNAME=username"
ENV TRANSMISSION_RPC_WHITELIST=127.0.0.1"
ENV TRANSMISSION_RPC_WHITELIST_ENABLED=false"
ENV TRANSMISSION_SCRAPE_PAUSED_TORRENTS_ENABLED=true"
ENV TRANSMISSION_SCRIPT_TORRENT_DONE_ENABLED=false"
ENV TRANSMISSION_SCRIPT_TORRENT_DONE_FILENAME="
ENV TRANSMISSION_SEED_QUEUE_ENABLED=false"
ENV TRANSMISSION_SEED_QUEUE_SIZE=10"
ENV TRANSMISSION_SPEED_LIMIT_DOWN=100"
ENV TRANSMISSION_SPEED_LIMIT_DOWN_ENABLED=false"
ENV TRANSMISSION_SPEED_LIMIT_UP=100"
ENV TRANSMISSION_SPEED_LIMIT_UP_ENABLED=false"
ENV TRANSMISSION_START_ADDED_TORRENTS=true"
ENV TRANSMISSION_TRASH_ORIGINAL_TORRENT_FILES=false"
ENV TRANSMISSION_UMASK=2"
ENV TRANSMISSION_UPLOAD_LIMIT=100"
ENV TRANSMISSION_UPLOAD_LIMIT_ENABLED=0"
ENV TRANSMISSION_UPLOAD_SLOTS_PER_TORRENT=14"
ENV TRANSMISSION_UTP_ENABLED=true"
ENV TRANSMISSION_WATCH_DIR=/data/watch"
ENV TRANSMISSION_WATCH_DIR_ENABLED=true"
ENV TRANSMISSION_HOME=/data/transmission-home"
ENV PYTHON_EGG_CACHE="/config/plugins/.python-eggs"

# Volumes
VOLUME /config
VOLUME /data
VOLUME /etc/openvpn

# Exposed ports
EXPOSE 9091

# Install runtime packages
RUN apk add --no-cache \
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
COPY transmission/ /etc/transmission/
COPY init/ /etc/init.d/

RUN chmod +x /etc/init.d/openvpn
#\
# && chmod +x /etc/init.d/deluged \
# && chmod +x /etc/init.d/deluge-web

RUN chmod +x /etc/openvpn/transmission-up.sh \
 && chmod +x /etc/openvpn/transmission-down.sh

#RUN rc-update add openvpn default
