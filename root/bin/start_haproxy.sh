#!/bin/bash

#Script initializes first compute node if no compute node is there
MASTER_IP=$(cat /etc/resolv.conf |grep nameserver|head -n1|awk '{print $2}')

function set_key {
   VAL=${2}
   echo "curl -s -o /dev/null -4 -XPUT http://${MASTER_IP}:4001/v2/keys${1} -d value=${2}"
   curl -s -o /dev/null -4 -XPUT http://${MASTER_IP}:4001/v2/keys${1} -d value=${2}
   SET_VAL=$(fetch_value ${1})
   if [ "X${VAL}" == "X${SET_VAL}" ];then
       echo "SET: ${1}:=${2}"
       return 0
   else
       echo "ERROR >> key: ${1}"
       echo "[ ${VAL} != ${SET_VAL} ]"
       return 1
   fi
}

function fetch_value {
   VALUE=$(curl -s -4 -L http://${MASTER_IP}:4001/v2/keys/${1}| python -mjson.tool|grep value|head -n1)
   RESULT=$(echo ${VALUE}|awk -F\: '{print $2}'|sed -s 's/"//g'|sed -e 's/ //g')
   if [ "X${RESULT}" == "X" ];then
      return 1
   fi
   echo ${RESULT}
}

function check_targets {
   HLIST="^($(curl -s -4 -L http://${MASTER_IP}:4001/v2/keys/helix/| python -mjson.tool|egrep -o "/helix/(.*)\""|sed -e 's/"//g'|awk -F\/ '{print $3}'|xargs|sed -e 's/ /|/g'))$"
   for host in grafana graphite graphite_api elk;do
      if [ $(echo ${host}|egrep -c "${HLIST}") -eq 0 ];then
          set_key /helix/${host}/A 127.17.0.2
          set_key /helix/${host}/AAAA "::1"
      fi
   done
}
check_targets

/sbin/haproxy -db -f /etc/haproxy/haproxy.cfg
