iptables -t nat -A OUTPUT -m owner --uid-owner 137 -j RETURN

for NET in $NON_TOR 127.0.0.0/9 127.128.0.0/10; do
    iptables -t nat -A OUTPUT -d $NET -j RETURN
done

iptables -t nat -A OUTPUT -p tcp -j DNAT --to-destination 127.0.0.1:15379
iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports 15379
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT   