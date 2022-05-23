#!/bin/bash
set -x

# test which google version is active
CHROME_OLD_VERSION="97.0.4692.71"
# Following version might not be accurate in the future.
# To be updated when new version is released.
CHROME_NEW_VERSION="101.0.4951.41"

wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo apt-get update --allow-releaseinfo-change

current_version=$(google-chrome --version)
older_version="Google Chrome $CHROME_OLD_VERSION "
echo '-----------------------'
echo "$current_version is active"
if [ "$current_version" = "$older_version" ] ; then
  echo "This is an older version of Google Chrome"
  echo "Switching to Google Chrome $CHROME_NEW_VERSION"
  echo '----------Uninstalling first-------------'
  sudo dpkg -r google-chrome-stable
  echo '----------Uninstalling finished-------------'

  sudo wget --no-check-certificate --no-verbose -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo apt install -y /tmp/chrome.deb
else
  echo "This is a newer version of Google Chrome"
  echo "Switching to Google Chrome $CHROME_OLD_VERSION"
  echo '----------Uninstalling first-------------'
  sudo dpkg -r google-chrome-stable
  echo '----------Uninstalling finished-------------'

  sudo wget --no-check-certificate --no-verbose -O /tmp/chrome.deb https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_OLD_VERSION}-1_amd64.deb
  sudo apt install -y /tmp/chrome.deb
fi
sudo rm /tmp/chrome.deb


exit $?