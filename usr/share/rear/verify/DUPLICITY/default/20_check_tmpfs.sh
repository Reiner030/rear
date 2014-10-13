# This file is part of Relax and Recover, licensed under the GNU General
# Public License. Refer to the included LICENSE for full text of license.

# mount tmpfs on /tmp if not present
mount | grep -q /tmp
if [[ $? -ne 0 ]]; then
  if [[ -z "$DUPLY_TEMPDIR" ]]; then
      LogPrint "File system /tmp not present - try to mount it via tmpfs"
      mount -t tmpfs  tmpfs  /tmp >&8
      LogIfError "Could not mount tmpfs on /tmp"
  else
      LogPrint "File system /tmp not present - and RAM is to small to hold Volume in tempfs"
      LogPrint "Try to use local folder /mnt/local/tmp"
      [[ ! -d /mnt/local/tmp ]]  && mkdir -m 4777 /mnt/local/tmp
      LogIfError "Could not create /tmp folder on local root partition"
  fi
fi
