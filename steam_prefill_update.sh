#!/bin/bash
# Specify your prefered SteamPrefill path:
PREFILL_PATH=/root/prefill

###############################################
# !!!DON'T CHANGE ANYTHING BELOW THIS LINE!!! #
################################################

CUR_V="$(find ${PREFILL_PATH}/ -type f -name "installedv*" 2>/dev/null)"
LAT_V="$(wget -qO- https://api.github.com/repos/tpill90/steam-lancache-prefill/releases/latest | grep tag_name | cut -d '"' -f4 | cut -d 'v' -f2)"

if [ -z "${LAT_V}" ]; then
  if [ -z "${CUR_V##*_}" ]; then
    echo "Something went horribly wrong, can't get latest version and found no installed version!"
    exit 1
  fi
  echo "Can't get latest version, falling back to installed version: ${CUR_V##*_}!"
fi

if [ ! -d "${PREFILL_PATH}" ]; then
  mkdir -p ${PREFILL_PATH}
fi

if [ -d /tmp/lancache ]; then
  rm -rf /tmp/lancache
fi

if [ -z "${CUR_V##*_}" ]; then
  echo "No installation found, installing version: ${LAT_V}, please wait..."
  mkdir -p /tmp/lancache
  cd /tmp/lancache
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O /tmp/lancache/lancache-v${LAT_V}.zip "https://github.com/tpill90/steam-lancache-prefill/releases/download/v${LAT_V}/SteamPrefill-${LAT_V}-linux-x64.zip" ; then
    echo "Successfully downloaded version: ${LAT_V}!"
  else
    echo "Something went wrong, can't download version: ${LAT_V}!"
    exit 1
  fi
  unzip -q /tmp/lancache/lancache-v${LAT_V}.zip
  cp $(find /tmp/lancache -type f -name SteamPrefill) ${PREFILL_PATH}/
  chmod +x ${PREFILL_PATH}/SteamPrefill
  rm -rf /tmp/lancache
  touch ${PREFILL_PATH}/installedv_${LAT_V}
  echo
  echo "Installed version: ${LAT_V}!"
  exit 0
elif [ "${CUR_V##*_}" != "${LAT_V}" ]; then
  echo "Version missmatch! Installing newer version: ${LAT_V}!"
  rm -f ${PREFILL_PATH}/installedv_*
  mkdir -p /tmp/lancache
  cd /tmp/lancache
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O /tmp/lancache/lancache-v${LAT_V}.zip "https://github.com/tpill90/steam-lancache-prefill/releases/download/v${LAT_V}/SteamPrefill-${LAT_V}-linux-x64.zip" ; then
    echo "Successfully downloaded version: ${LAT_V}!"
  else
    echo "Something went wrong, can't download version: ${LAT_V}!"
    exit 1
  fi
  unzip /tmp/lancache/lancache-v${LAT_V}.zip
  cp $(find /tmp/lancache -type f -name SteamPrefill) ${PREFILL_PATH}/
  chmod +x ${PREFILL_PATH}/SteamPrefill
  rm -rf /tmp/lancache
  touch ${PREFILL_PATH}/installedv_${LAT_V}
  echo
  echo "Updated from version: "${CUR_V##*_}" to version: ${LAT_V}!"
  exit 0
elif [ "${CUR_V##*_}" == "${LAT_V}" ]; then
    echo "Nothing to do version: "${CUR_V##*_}" up-to-date!"
    exit 0
fi
