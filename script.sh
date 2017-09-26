export DEBIAN_FRONTEND=noninteractive

apt-get -y update
apt-get -y install python-software-properties unzip wget python sqlite3

rm -rf /var/lib/apt/lists/*
rm -f /var/log/dpkg.log
rm -rf /var/log/apt
rm -rf /var/cache/apt

SCRIPT_DIR="/opt/image"
START_CLIENT="${SCRIPT_DIR}/start-seaclient.sh"
START_CLIENT_USER="${SCRIPT_DIR}/start-seaclient-user.sh"
START_CLIENT_AUTOSTART="/etc/my_init.d/50_start-seaclient.sh"
ADD_SYNC="${SCRIPT_DIR}/addsync"
ADD_SYNC_USER="${SCRIPT_DIR}/addsync-user"
ADD_SYNC_ROOT="/addsync"
CREATE_USER="${SCRIPT_DIR}/create-user"
SEAFILE_VERSION="4.3.2"
SEAFILE_TMP_DIR="seafile-cli-${SEAFILE_VERSION}"
SEAFILE_FILENAME="seafile-cli_${SEAFILE_VERSION}_x86-64.tar.gz"
# SEAFILE_URL="https://bitbucket.org/haiwen/seafile/downloads/${SEAFILE_FILENAME}"
SEAFILE_URL="https://bintray.com/artifact/download/seafile-org/seafile/${SEAFILE_FILENAME}"

DATA_DIR="/data"
DATA_CCNET_DIR="${DATA_DIR}/config/ccnet"
DATA_CLIENT_DIR="${DATA_DIR}/config/client"
DATA_SEAFILE_DIR="${DATA_DIR}/files"

USER_NAME="seafile"
GROUP_NAME="seafile"
HOME_DIR="/home/${USER_NAME}"
SEAFILE_APPLI_DIR="/opt/seaclient"
CCNET_DIR="${HOME_DIR}/.ccnet"
SEAFILE_CLIENT_DIR="${HOME_DIR}/.seafile-client"
SEAFILE_CLIENT_BIN="${SEAFILE_APPLI_DIR}/seaf-cli"

pip install --upgrade pip
pip install --upgrade simplejson

mkdir -p "${SCRIPT_DIR}"

cd /tmp
wget "${SEAFILE_URL}"
tar xvzf "${SEAFILE_FILENAME}"
mkdir -p "${HOME_DIR}"
rm -f "${SEAFILE_FILENAME}"
mv "/tmp/${SEAFILE_TMP_DIR}" "${SEAFILE_APPLI_DIR}"

ln -s "${DATA_CCNET_DIR}" "${CCNET_DIR}"
ln -s "${DATA_CLIENT_DIR}" "${SEAFILE_CLIENT_DIR}"

ln -s "${ADD_SYNC}" "${ADD_SYNC_ROOT}"
ln -s "${START_CLIENT}" "${START_CLIENT_AUTOSTART}"

# Remove /etc/service/syslog-forwarder as logs are getting in the way of the interactive script
rm -rf /etc/service/syslog-forwarder

#------------------------------------------------
cat <<__END__ > "${CREATE_USER}"
[ -z "\${APP_UID}" ] && APP_UID=0
[ -z "\${APP_GID}" ] && APP_GID=0
sed -i 's/^${USER_NAME}:.*//' /etc/passwd
sed -i 's/^${GROUP_NAME}:.*//' /etc/group
echo "${USER_NAME}:x:\${APP_UID}:\${APP_GID}:${GROUP_NAME}:${HOME_DIR}:/bin/false" >> /etc/passwd
echo "${GROUP_NAME}:x:\${APP_GID}:${USER_NAME}" >> /etc/group
mkdir -p "${DATA_CCNET_DIR}"
mkdir -p "${DATA_CLIENT_DIR}"
mkdir -p "${DATA_SEAFILE_DIR}"
chown ${USER_NAME}:${GROUP_NAME} "${HOME_DIR}"
chown ${USER_NAME}:${GROUP_NAME} -h "${CCNET_DIR}" "${SEAFILE_CLIENT_DIR}"
chown ${USER_NAME}:${GROUP_NAME} -R "${DATA_DIR}"
chown ${USER_NAME}:${GROUP_NAME} -R "${SEAFILE_APPLI_DIR}"
chmod 0700 "${DATA_CCNET_DIR}"
__END__
chmod +x "${CREATE_USER}"
#------------------------------------------------
cat <<__END__ > "${START_CLIENT_USER}"
#!/usr/bin/env sh
if [ ! -e ${CCNET_DIR}/seafile.ini ]
then
    "${SEAFILE_CLIENT_BIN}" init -c ${CCNET_DIR}2 -d ${SEAFILE_CLIENT_DIR}
    mv ${CCNET_DIR}2/* ${CCNET_DIR}
fi
"${SEAFILE_CLIENT_BIN}" start
__END__
chmod +x "${START_CLIENT_USER}"
#------------------------------------------------
cat <<__END__ > "${START_CLIENT}"
#!/usr/bin/env sh
. "${CREATE_USER}"
HOME="${HOME_DIR}" sudo -E -u "${USER_NAME}" "${START_CLIENT_USER}"
__END__
chmod +x "${START_CLIENT}"
#------------------------------------------------
cat <<__END__ > "${ADD_SYNC_USER}"
#!/usr/bin/env sh

echo "Forlder name ? "
read folder
echo "Folder ID ? "
read id
echo "Server url ? "
read url
echo "login mail ? "
read login
mkdir "${DATA_SEAFILE_DIR}/\$folder"
"${SEAFILE_CLIENT_BIN}" sync -d "${DATA_SEAFILE_DIR}/\$folder" -l \$id -s \$url -u \$login
__END__
chmod +x "${ADD_SYNC_USER}"
#------------------------------------------------
cat <<__END__ > "${ADD_SYNC}"
#!/usr/bin/env sh
. "${CREATE_USER}"
HOME="${HOME_DIR}" sudo -E -u "${USER_NAME}" "${ADD_SYNC_USER}"
__END__
chmod +x "${ADD_SYNC}"
#------------------------------------------------

rm -f "/tmp/script.sh"

