#!/bin/bash
# Simple Linux Security Audit Script - Run as root

echo -e "\n=== Local Users and Groups ==="
awk -F: '{print "User: " $1 " UID: " $3 " GID: " $4 " Home: " $6 " Shell: " $7}' /etc/passwd
echo -e "\nGroups:"
cat /etc/group

echo -e "\n=== Users with password NEVER changed or OLD (last change >180 days) ==="
while IFS=: read -r user pw last min max warn inactive expire; do
  if [ "$pw" = "*" ] || [ "$pw" = "!" ] || [ -z "$pw" ]; then
    echo "$user - Password disabled/locked/empty"
  elif [ -z "$last" ] || [ "$last" -lt 0 ]; then
    echo "$user - Password NEVER set"
  else
    days=$(( ( $(date +%s) / 86400 ) - last ))
    if [ $days -gt 180 ]; then
      echo "$user - Password age: $days days"
    fi
  fi
done < /etc/shadow

echo -e "\n=== Users with potentially weak passwords (empty or no complexity - check manually) ==="
while IFS=: read -r user pw last min max warn inactive expire; do
  if [ -z "$pw" ] || [ "$pw" = "!" ] || [ "$pw" = "*" ]; then
    echo "$user - No password or locked (weak if enabled)"
  fi
done < /etc/shadow
echo "(For complexity, check /etc/pam.d/password-auth or common-password)"

echo -e "\n=== Admin Users (sudoers or UID 0) ==="
getent group sudo wheel admin | awk -F: '{print "Group " $1 ": " $4}'
awk -F: '$3 == 0 {print $1}' /etc/passwd

echo -e "\n=== Users with SSH Access (non-nologin shell + key/password allowed) ==="
awk -F: '$7 !~ /nologin|false/ {print $1}' /etc/passwd
echo "(Check /etc/ssh/sshd_config for AllowUsers/Groups)"

echo -e "\n=== Installed Software (Debian/Ubuntu: dpkg, RedHat: rpm) ==="
if command -v dpkg >/dev/null; then
  dpkg -l | grep ^ii
elif command -v rpm >/dev/null; then
  rpm -qa
else
  echo "No dpkg or rpm found"
fi

echo -e "\n=== Pending Updates ==="
if command -v apt >/dev/null; then
  apt list --upgradable
elif command -v yum >/dev/null; then
  yum check-update
elif command -v dnf >/dev/null; then
  dnf check-update
else
  echo "No apt/yum/dnf found"
fi
