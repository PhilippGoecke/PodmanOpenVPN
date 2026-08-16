#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="openvpn-as"
IMAGE="docker.io/openvpn/openvpn-as:latest"
DATA_DIR="$(pwd)/openvpn-as-config"

# Create persistent data directory
mkdir -p "${DATA_DIR}"

# Remove existing container if present
if podman container exists "${CONTAINER_NAME}"; then
    echo "Removing existing container ${CONTAINER_NAME}..."
    podman rm -f "${CONTAINER_NAME}"
fi

echo "Starting OpenVPN Access Server..."
podman run -d \
    --name "${CONTAINER_NAME}" \
    --cap-add=NET_ADMIN \
    --cap-add=MKNOD \
    --device /dev/net/tun \
    -p 943:943/tcp \
    -p 443:443/tcp \
    -p 1194:1194/udp \
    -v "${DATA_DIR}:/openvpn:Z" \
    --restart unless-stopped \
    "${IMAGE}"

echo "OpenVPN Access Server started."
echo "Admin UI:  https://localhost:943/admin"
echo "Client UI: https://localhost:943/"
echo "Get initial openvpn admin password with:"
echo "  podman exec -it ${CONTAINER_NAME} cat /usr/local/openvpn_as/init.log | grep password"
podman exec -it ${CONTAINER_NAME} cat /usr/local/openvpn_as/init.log | grep password

echo ""
echo "Reset user password via CLI:"
echo "  podman exec -it ${CONTAINER_NAME} sacli --user <username> --new_pass 'YourNewPasswordHere' SetLocalPassword
echo "  podman exec -it ${CONTAINER_NAME} sacli start

echo ""
echo "To create a client user:"
echo "  podman exec -it ${CONTAINER_NAME} sacli --user <username> --key type --value user_connect UserPropPut"
echo "  podman exec -it ${CONTAINER_NAME} sacli --user <username> --new_pass '<password>' SetLocalPassword"
echo "Then download the client profile:"
echo "  podman exec -it ${CONTAINER_NAME} sacli --user <username> GetUserlogin > <username>.ovpn"
echo "Or log in as the user at https://localhost:943/ to download the profile."
