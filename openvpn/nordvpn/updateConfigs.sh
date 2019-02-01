#!/bin/bash

set -e

# If the script is called from elsewhere
cd "${0%/*}"

# Delete everything (not this script though)
find . ! -name '*.sh' -delete

# Get updated configuration zip
curl -kL https://nordvpn.com/api/files/zip -o nordvpn.zip \
  && unzip -j nordvpn.zip && rm nordvpn.zip

for configFile in $(find . -name '*.ovpn')
do
  if [[ -L ${configFile} ]]; then
    continue # Don't edit symbolic links (default.ovpn)
  fi
  # Ensure linux line endings
  dos2unix $configFile
  # Absolute reference to ca cert
  sed -i "s/ca .*\.crt/ca \/etc\/openvpn\/$provider\/ca.crt/g" "$configFile"
  # Absolute reference to Wdc key file
  sed -i "s/tls-auth Wdc.key 1/tls-auth \/etc\/openvpn\/$provider\/Wdc.key 1/g" "$configFile"
  # Absolute reference to crl
  sed -i "s/crl-verify.*\.pem/crl-verify \/etc\/openvpn\/$provider\/crl.pem/g" "$configFile"
  # Set user-pass file location
  sed -i "s/auth-user-pass.*/auth-user-pass \/config\/openvpn-credentials.txt/g" "$configFile"
done

# Create symlink for default.ovpn
ln -s it61.nordvpn.com.udp1194.ovpn default.ovpn

