if [ $# -lt 3 ]; then
	echo "./start.sh proxy_host proxy_port app_uid [redirect_type(true, false, https)]"
	exit 0
fi

proxyHost=$1
proxyPort=$2
uid=$3
basePath=`pwd`
type=http
auth=false
redirect=true
if [ $# -eq 4 ]; then
	redirect=$4
fi

PATH=$basePath:$PATH

$basePath/proxy.sh $basePath start $type $proxyHost $proxyPort $auth "" ""
	
iptables -t nat -A OUTPUT -p tcp -d $proxyHost -j RETURN
# iptables -t nat -A OUTPUT -p tcp -d 127.0.0.1 -j RETURN

case $redirect in
true)
    iptables -t nat -m owner --uid-owner $uid -A OUTPUT -p tcp --dport 80 -j REDIRECT --to 8123
    iptables -t nat -m owner --uid-owner $uid -A OUTPUT -p tcp --dport 443 -j REDIRECT --to 8124
    iptables -t nat -m owner --uid-owner $uid -A OUTPUT -p tcp --dport 5228 -j REDIRECT --to 8124
;;
false)
    iptables -t nat -m owner --uid-owner $uid -A OUTPUT -p tcp --dport 80 -j DNAT --to-destination 127.0.0.1:8123
    iptables -t nat -m owner --uid-owner $uid -A OUTPUT -p tcp --dport 443 -j DNAT --to-destination 127.0.0.1:8124
    iptables -t nat -m owner --uid-owner $uid -A OUTPUT -p tcp --dport 5228 -j DNAT --to-destination 127.0.0.1:8124
;;
https)
	iptables -t nat -m owner --uid-owner $uid -A OUTPUT -p tcp -j DNAT --to-destination 127.0.0.1:8124
;;
esac
