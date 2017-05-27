#!/usr/bin/env bash
default_conf="/etc/sniproxy.conf"
conf=/sniproxy/sniproxy.conf
back_conf=/etc/sniproxy.conf.back

if ! [ -f "$back_conf" ]; then
  cp $default_conf $back_conf
fi

if ! [ -f "$conf" ]; then
  cp $default_conf $conf
else
  cp $conf $default_conf
fi


# file tag data
_insert() {
  _file="$1"
  _tag="$2"
  _data="$3"
  
  if [ -z "$_data" ]; then
    echo "Usage: _insert file tag data"
    return 1
  fi
  
  i="$(grep -n -- "$_tag" "$_file" | cut -d : -f 1)"
  if [ -z "$i" ]; then
    echo "Can not find start line: $_tag"
    return 1
  fi
  

  
  _temp=$(mktemp)
  head -n $i $_file >$_temp
  
  echo "$_data" >>$_temp
  
  i=$(($i + 1))
  sed -n "${i},99999p" "$_file" >>$_temp
  
  cat $_temp >$_file
  rm -rf $_temp
}

#add sniproxy
# domain target_ip [target_port]
addhttp() {
  _domain="$1"
  _ip="$2"
  _port="$3"

  if [ -z "$_ip" ]; then
    echo "Usage: addhttp domain target_ip [target_port]"
    return 1
  fi

  if _insert $conf "table http_hosts {" "$_domain $_ip:${_port:-80}"; then
    echo OK
    cp $conf $default_conf
    service sniproxy restart
  else
    echo Error
    return 1
  fi
}

#add sniproxy
# domain target_ip [target_port]
addssl() {
  _domain="$1"
  _ip="$2"
  _port="$3"

  if [ -z "$_ip" ]; then
    echo "Usage: addssl domain target_ip [target_port]"
    return 1
  fi

  if _insert $conf "table https_hosts {" "$_domain $_ip:${_port:-443}"; then
    echo OK
    cp $conf $default_conf
    service sniproxy restart
  else
    echo Error
    return 1
  fi
}

#add sniproxy
# domain target_ip [target_port]
add() {
  _domain="$1"
  _ip="$2"
  _port="$3"
  _sslport="$4"
  
  if [ -z "$_ip" ]; then
    echo "Usage: add domain target_ip [target_port] [target_ssl_port]"
    return 1
  fi
  
  if _insert $conf "table http_hosts {" "$_domain $_ip:${_port:-80}" \
    && _insert $conf "table https_hosts {" "$_domain $_ip:${_port:-443}"; then
    cp $conf $default_conf
    service sniproxy restart
  else
    echo Error
    return 1
  fi
  
}



if [ "$1" ]; then
  "$@"
else
  service sniproxy start && tail -f /dev/null 
fi



