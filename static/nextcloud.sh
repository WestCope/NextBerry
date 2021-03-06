#!/bin/bash
# shellcheck disable=2034,2059,2140,2004
true
# Tech and Me © - 2017, https://www.techandme.se/

version_gt() {
    local v1 v2 IFS=.
    read -ra v1 <<< "$1"
    read -ra v2 <<< "$2"
    printf -v v1 %03d "${v1[@]}"
    printf -v v2 %03d "${v2[@]}"
    [[ $v1 > $v2 ]]
}

upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
secs=$((${upSeconds}%60))
mins=$((${upSeconds}/60%60))
hours=$((${upSeconds}/3600%24))
days=$((${upSeconds}/86400))
UPTIME=$(printf "%d days, %02dh%02dm%02ds" "$days" "$hours" "$mins" "$secs")
REPO="https://raw.githubusercontent.com/techandme/NextBerry/master/"
CURRENTVERSION=$(sed '1q;d' /var/scripts/.version-nc)
CLEANVERSION=$(sed '2q;d' /var/scripts/.version-nc)
GITHUBVERSION=$(curl -s $REPO/version)
SCRIPTS="/var/scripts"
FIGLET="/usr/bin/figlet"
TEMP=$(vcgencmd measure_temp)
CPUFREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
COREVOLT=$(vcgencmd measure_volts core)
MEMARM=$(vcgencmd get_mem arm)
MEMGPU=$(vcgencmd get_mem gpu)
WANIP4=$(curl -s ipinfo.io/ip -m 5)
WANIP6=$(curl -s 6.ifcfg.me -m 5)
ADDRESS=$(hostname -I | cut -d ' ' -f 1)
RELEASE=$(lsb_release -s -d)
HTML=/var/www
NCREPO="https://download.nextcloud.com/server/releases"
CURRENTVERSIONNC=$(cat $SCRIPTS/.versionnc)
NCVERSION=$(curl -s -m 900 $NCREPO/ | sed --silent 's/.*href="nextcloud-\([^"]\+\).zip.asc".*/\1/p' | sort --version-sort | tail -1)
COLOR_PURPLE='\e[1;95m'
COLOR_CYAN='\e[1;96m'
COLOR_WHITE='\033[1;37m'
COLOR_DEFAULT='\033[0m'
OS=$(printf "Operating system: %s (%s %s %s)\n" "$RELEASE" "$(uname -o)" "$(uname -r)" "$(uname -m)")
clear
echo -e "$COLOR_WHITE $($FIGLET -ckw 80 -f small NextBerry "$CLEANVERSION") $COLOR_DEFAULT"
echo -e "$COLOR_WHITE                           https://www.techandme.se $COLOR_DEFAULT"
echo -e "$COLOR_WHITE =============================================================================== $COLOR_DEFAULT"
echo -e "$COLOR_WHITE Nextberry: $CLEANVERSION - Nextcloud: v$CURRENTVERSIONNC - Uptime: $UPTIME $COLOR_DEFAULT"
echo -e "$COLOR_WHITE =============================================================================== $COLOR_DEFAULT"
echo -e "$COLOR_WHITE RPI: $TEMP - CPU freq: $CPUFREQ - $COREVOLT - MEM: $MEMGPU $MEMARM $COLOR_DEFAULT"
echo -e "$COLOR_WHITE =============================================================================== $COLOR_DEFAULT"
echo -e "$COLOR_WHITE $OS $COLOR_DEFAULT"
echo -e "$COLOR_WHITE =============================================================================== $COLOR_DEFAULT"
echo -e "$COLOR_WHITE WAN IPv4: $COLOR_PURPLE$WANIP4 $COLOR_WHITE- WAN IPv6: $COLOR_WHITE$WANIP6 $COLOR_DEFAULT"
echo -e "$COLOR_WHITE LAN IPv4: $COLOR_PURPLE$ADDRESS $COLOR_DEFAULT"
echo -e "$COLOR_WHITE =============================================================================== $COLOR_DEFAULT"
if [ -f $SCRIPTS/.menu ];	then
echo -e "$COLOR_WHITE To upload your installation log, type:        $COLOR_PURPLE sudo install-log $COLOR_DEFAULT"
echo -e "$COLOR_WHITE To view your firewall rules, type:            $COLOR_PURPLE sudo firewall-rules $COLOR_DEFAULT"
echo -e "$COLOR_WHITE To connect to a wifi network, type:           $COLOR_PURPLE sudo wireless $COLOR_DEFAULT"
echo -e "$COLOR_WHITE To auto install Letsencrypt certs, type:      $COLOR_PURPLE sudo activate-ssl $COLOR_DEFAULT"
echo -e "$COLOR_WHITE To view RPI config settings, type:            $COLOR_PURPLE sudo rpi-conf $COLOR_DEFAULT"
echo -e "$COLOR_WHITE To monitor your system, type:                 $COLOR_PURPLE sudo htop $COLOR_DEFAULT"
echo -e "$COLOR_WHITE                                               $COLOR_PURPLE sudo fs-size $COLOR_DEFAULT"
echo -e "$COLOR_WHITE To view advanced config, type:                $COLOR_PURPLE sudo raspi-config $COLOR_DEFAULT"
fi
echo -e "$COLOR_WHITE Toggle this menu on and of:                   $COLOR_PURPLE sudo menu-toggle $COLOR_DEFAULT"
# Log file check
if [ -f $SCRIPTS/.pastebinit ];	then
  INSLOG=$(cat $SCRIPTS/.pastebinit)
  echo -e "$COLOR_WHITE =============================================================================== $COLOR_DEFAULT"
  echo -e "$COLOR_CYAN Your installation log: $INSLOG $COLOR_DEFAULT"
  echo -e "$COLOR_WHITE To remove this notification: sudo rm $SCRIPTS/.pastebinit"
fi
echo -e "$COLOR_WHITE =============================================================================== $COLOR_DEFAULT"
# NextBerry version check
if [ "$GITHUBVERSION" -gt "$CURRENTVERSION" ]; then
  echo -e "$COLOR_LIGHT_GREEN NextBerry update available, run: sudo bash /home/ncadmin/nextberry-upgrade.sh $COLOR_DEFAULT"
  echo -e "$COLOR_WHITE =============================================================================== $COLOR_DEFAULT"
  if [ -f /home/ncadmin/nextberry-upgrade.sh ];	then
      rm /home/ncadmin/nextberry-upgrade.sh
  fi
      wget -q https://raw.githubusercontent.com/techandme/NextBerry/master/static/nextberry-upgrade.sh -P /home/ncadmin/ && chmod +x /home/ncadmin/nextberry-upgrade.sh
      if [[ $? -gt 0 ]]; then
      echo -e "$COLOR_WHITE Download of update script failed. Please file a bug report on https://github.com/techandme/NextBerry/issues/new $COLOR_DEFAULT"
      echo -e "$COLOR_WHITE =============================================================================== $COLOR_DEFAULT"
      fi
fi
# Nextcloud version check
if version_gt "$NCVERSION" "$CURRENTVERSIONNC"
then
  echo -e "$COLOR_LIGHT_GREEN Nextcloud update available, run: sudo bash $SCRIPTS/update.sh $COLOR_DEFAULT"
  echo -e "$COLOR_WHITE =============================================================================== $COLOR_DEFAULT"
fi
exit 0
