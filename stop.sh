basePath=`pwd`

iptables -t nat -F OUTPUT
$basePath/proxy.sh $basePath stop
