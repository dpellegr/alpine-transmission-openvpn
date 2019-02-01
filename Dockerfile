FROM alpine:latest
MAINTAINER Oskari Rauta <oskari.rauta@gmail.com>

# Environment variables
ENV LOCAL_NETWORK="" \
    OPENVPN_USERNAME=**None** \
    OPENVPN_PASSWORD=**None** \
    OPENVPN_PROVIDER=**None** \
    OPENVPN_CONFIG=**None** \
    PUID=1001 \
    PGID=2001 \
    TRANSMISSION_ALT_SPEED_DOWN="50" \
    TRANSMISSION_ALT_SPEED_ENABLED="false" \
    TRANSMISSION_ALT_SPEED_TIME_BEGIN="540" \
    TRANSMISSION_ALT_SPEED_TIME_DAY="127" \
    TRANSMISSION_ALT_SPEED_TIME_ENABLED="false" \
    TRANSMISSION_ALT_SPEED_TIME_END="1020" \
    TRANSMISSION_ALT_SPEED_UP="50" \
    TRANSMISSION_BIND_ADDRESS_IPV4="0.0.0.0" \
    TRANSMISSION_BIND_ADDRESS_IPV6="::" \
    TRANSMISSION_BLOCKLIST_ENABLED="false" \
    TRANSMISSION_BLOCKLIST_URL="http://www.example.com/blocklist" \
    TRANSMISSION_CACHE_SIZE_MB="4" \
    TRANSMISSION_DHT_ENABLED="true" \
    TRANSMISSION_DOWNLOAD_DIR="/data/downloads" \
    TRANSMISSION_DOWNLOAD_LIMIT="100" \
    TRANSMISSION_DOWNLOAD_LIMIT_ENABLED="0" \
    TRANSMISSION_DOWNLOAD_QUEUE_ENABLED="true" \
    TRANSMISSION_DOWNLOAD_QUEUE_SIZE="5" \
    TRANSMISSION_ENCRYPTION="true" \
    TRANSMISSION_IDLE_SEEDING_LIMIT="30" \
    TRANSMISSION_IDLE_SEEDING_LIMIT_ENABLED="false" \
    TRANSMISSION_INCOMPLETE_DIR="/data/incomplete" \
    TRANSMISSION_INCOMPLETE_DIR_ENABLED="true" \
    TRANSMISSION_LPD_ENABLED="false" \
    TRANSMISSION_MAX_PEERS_GLOBAL="200" \
    TRANSMISSION_MESSAGE_LEVEL="2" \
    TRANSMISSION_PEER_CONGESTION_ALGORITHM="" \
    TRANSMISSION_PEER_ID_TTL_HOURS="6" \
    TRANSMISSION_PEER_LIMIT_GLOBAL="200" \
    TRANSMISSION_PEER_LIMIT_PER_TORRENT="50" \
    TRANSMISSION_PEER_PORT="51413" \
    TRANSMISSION_PEER_PORT_RANDOM_HIGH="65535" \
    TRANSMISSION_PEER_PORT_RANDOM_LOW="49152" \
    TRANSMISSION_PEER_PORT_RANDOM_ON_START="false" \
    TRANSMISSION_PEER_SOCKET_TOS="default" \
    TRANSMISSION_PEX_ENABLED="true" \
    TRANSMISSION_PORT_FORWARDING_ENABLED="false" \
    TRANSMISSION_PREALLOCATION="true" \
    TRANSMISSION_PREFETCH_ENABLED="true" \
    TRANSMISSION_QUEUE_STALLED_ENABLED="true" \
    TRANSMISSION_QUEUE_STALLED_MINUTES="20" \
    TRANSMISSION_RATIO_LIMIT="2" \
    TRANSMISSION_RATIO_LIMIT_ENABLED="false" \
    TRANSMISSION_RENAME_PARTIAL_FILES="true" \
    TRANSMISSION_RPC_AUTHENTICATION_REQUIRED="false" \
    TRANSMISSION_RPC_BIND_ADDRESS="0.0.0.0" \
    TRANSMISSION_RPC_ENABLED="true" \
    TRANSMISSION_RPC_PASSWORD="password" \
    TRANSMISSION_RPC_PORT="9091" \
    TRANSMISSION_RPC_URL="/transmission/" \
    TRANSMISSION_RPC_USERNAME="username" \
    TRANSMISSION_RPC_WHITELIST="127.0.0.1, 192.168.*.*" \
    TRANSMISSION_RPC_WHITELIST_ENABLED="true" \
    TRANSMISSION_RPC_HOST_WHITELIST="" \
    TRANSMISSION_RPC_HOST_WHITELIST_ENABLED="true" \
    TRANSMISSION_SCRAPE_PAUSED_TORRENTS_ENABLED="true" \
    TRANSMISSION_SCRIPT_TORRENT_DONE_ENABLED="false" \
    TRANSMISSION_SCRIPT_TORRENT_DONE_FILENAME="" \
    TRANSMISSION_SEED_QUEUE_ENABLED="false" \
    TRANSMISSION_SEED_QUEUE_SIZE="5" \
    TRANSMISSION_SPEED_LIMIT_DOWN="100" \
    TRANSMISSION_SPEED_LIMIT_DOWN_ENABLED="false" \
    TRANSMISSION_SPEED_LIMIT_UP="100" \
    TRANSMISSION_SPEED_LIMIT_UP_ENABLED="false" \
    TRANSMISSION_START_ADDED_TORRENTS="true" \
    TRANSMISSION_TRASH_ORIGINAL_TORRENT_FILES="false" \
    TRANSMISSION_UMASK="2" \
    TRANSMISSION_UPLOAD_LIMIT="100" \
    TRANSMISSION_UPLOAD_LIMIT_ENABLED="false" \
    TRANSMISSION_UPLOAD_SLOTS_PER_TORRENT="2" \
    TRANSMISSION_UTP_ENABLED="true" \
    TRANSMISSION_WATCH_DIR="/data/watch" \
    TRANSMISSION_WATCH_DIR_ENABLED="true" \
    TRANSMISSION_HOME="/config" \
    PYTHON_EGG_CACHE="/config/plugins/.python-eggs"

RUN mkdir -p /data \
 && mkdir -p /etc/openvpn

# Volumes
VOLUME /config
VOLUME /data/downloads
VOLUME /data/incomplete
VOLUME /data/watch
VOLUME /etc/scripts

# Exposed ports
EXPOSE 9091

# Install runtime packages
RUN apk add --no-cache \
	openrc \
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
	transmission-daemon \
	openvpn \
	dcron

# Tell openrc its running inside a container, till now that has meant LXC
RUN sed -i 's/#rc_sys=""/rc_sys="lxc"/g' /etc/rc.conf \
# Tell openrc loopback and net are already there, since docker handles the networking
 && echo 'rc_provide="loopback net"' >> /etc/rc.conf \
# Allow passing of environment variables for init scripts
 && echo 'rc_env_allow="*"' >> /etc/rc.conf \
# no need for loggers
 && sed -i 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf \
# remove sysvinit runlevels
 && sed -i '/::sysinit:/d' /etc/inittab \
# can't get ttys unless you run the container in privileged mode
 && sed -i '/tty/d' /etc/inittab \
# can't set hostname since docker sets it
 && sed -i 's/hostname $opts/# hostname $opts/g' /etc/init.d/hostname \
# can't mount tmpfs since not privileged
 && sed -i 's/mount -t tmpfs/# mount -t tmpfs/g' /lib/rc/sh/init.sh \
# can't do cgroups
 && sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh

RUN apk add --no-cache --repository "http://nl.alpinelinux.org/alpine/edge/testing" \
	dockerize

# cleanup
RUN rm -rf /root/.cache

# Create user and group
RUN addgroup -S -g 2001 media \
 && usermod -d /config -u 1001 -G media -s /bin/nologin transmission

# add local files and replace init script
COPY openvpn/ /etc/openvpn/
COPY transmission/ /etc/transmission/
COPY init/ /etc/init.d/
COPY /cron/root /etc/crontabs/root

RUN rc-update add openvpn-serv default \
 && rc-update add dcron default

ENTRYPOINT ["/sbin/init"]

