#!/usr/bin/env bash

if [ "$1" == "start" ]; then

    touch /etc/tor/torrc.1
    echo "SocksPort 9001" >> /etc/tor/torrc.1
    echo "ControlPort 9091" >> /etc/tor/torrc.1
    echo "DNSPort 9053" >> /etc/tor/torrc.1
    echo "DataDirectory /var/lib/tor" >> /etc/tor/torrc.1
    echo "AutomapHostsOnResolve 1" >> /etc/tor/torrc.1
    echo "AutomapHostsSuffixes .exit,.onion" >> /etc/tor/torrc.1

    touch /etc/tor/torrc.2
    echo "SocksPort 9002" >> /etc/tor/torrc.2
    echo "ControlPort 9092" >> /etc/tor/torrc.2
    echo "DataDirectory /var/lib/tor" >> /etc/tor/torrc.2

    touch /etc/tor/torrc.3
    echo "SocksPort 9003" >> /etc/tor/torrc.3
    echo "ControlPort 9093" >> /etc/tor/torrc.3
    echo "DataDirectory /var/lib/tor" >> /etc/tor/torrc.3

    touch /etc/tor/torrc.4
    echo "SocksPort 9004" >> /etc/tor/torrc.4
    echo "ControlPort 9094" >> /etc/tor/torrc.4
    echo "DataDirectory /var/lib/tor" >> /etc/tor/torrc.4

    touch /etc/tor/torrc.5
    echo "SocksPort 9005" >> /etc/tor/torrc.5
    echo "ControlPort 9095" >> /etc/tor/torrc.5
    echo "DataDirectory /var/lib/tor" >> /etc/tor/torrc.5


    sudo -u debian-tor tor -f /etc/tor/torrc.1 --RunAsDaemon 1 --CookieAuthentication 0 --SocksBindAddress 127.0.0.1 --NewCircuitPeriod 15 --MaxCircuitDirtiness 15 --NumEntryGuards 8 --CircuitBuildTimeout 5 --ExitRelay 0 --RefuseUnknownExits 0 --ClientOnly 1 --StrictNodes 1 --AllowSingleHopCircuits 1
    sudo -u debian-tor tor -f /etc/tor/torrc.2 --RunAsDaemon 1 --CookieAuthentication 0 --SocksBindAddress 127.0.0.1 --NewCircuitPeriod 15 --MaxCircuitDirtiness 15 --NumEntryGuards 8 --CircuitBuildTimeout 5 --ExitRelay 0 --RefuseUnknownExits 0 --ClientOnly 1 --StrictNodes 1 --AllowSingleHopCircuits 1
    sudo -u debian-tor tor -f /etc/tor/torrc.3 --RunAsDaemon 1 --CookieAuthentication 0 --SocksBindAddress 127.0.0.1 --NewCircuitPeriod 15 --MaxCircuitDirtiness 15 --NumEntryGuards 8 --CircuitBuildTimeout 5 --ExitRelay 0 --RefuseUnknownExits 0 --ClientOnly 1 --StrictNodes 1 --AllowSingleHopCircuits 1
    sudo -u debian-tor tor -f /etc/tor/torrc.4 --RunAsDaemon 1 --CookieAuthentication 0 --SocksBindAddress 127.0.0.1 --NewCircuitPeriod 15 --MaxCircuitDirtiness 15 --NumEntryGuards 8 --CircuitBuildTimeout 5 --ExitRelay 0 --RefuseUnknownExits 0 --ClientOnly 1 --StrictNodes 1 --AllowSingleHopCircuits 1
    sudo -u debian-tor tor -f /etc/tor/torrc.5 --RunAsDaemon 1 --CookieAuthentication 0 --SocksBindAddress 127.0.0.1 --NewCircuitPeriod 15 --MaxCircuitDirtiness 15 --NumEntryGuards 8 --CircuitBuildTimeout 5 --ExitRelay 0 --RefuseUnknownExits 0 --ClientOnly 1 --StrictNodes 1 --AllowSingleHopCircuits 1

    cp /etc/resolv.conf /etc/resolv.conf_OLD
    echo "nameserver 127.0.0.1" > /etc/resolv.conf

    kill -9 $(pgrep -fi dnsmasq)

    touch /etc/dnsmasq.conf
    echo "no-resolv" >> /etc/dnsmasq.conf
    echo "server=127.0.0.1#9053" >> /etc/dnsmasq.conf
    echo "listen-address=127.0.0.1" >> /etc/dnsmasq.conf

    dnsmasq

    cp ./haproxy.cfg ./haproxy.cfg_OLD
    echo "server            socks-process-9001 127.0.0.1:9001 check fall 3 rise 2" >> ./haproxy.cfg
    echo "server            socks-process-9002 127.0.0.1:9001 check fall 3 rise 2" >> ./haproxy.cfg
    echo "server            socks-process-9003 127.0.0.1:9001 check fall 3 rise 2" >> ./haproxy.cfg
    echo "server            socks-process-9004 127.0.0.1:9001 check fall 3 rise 2" >> ./haproxy.cfg
    echo "server            socks-process-9005 127.0.0.1:9001 check fall 3 rise 2" >> ./haproxy.cfg

    haproxy -f ./haproxy.cfg

    privoxy ./privoxy.cfg

else
    rm -rf /etc/tor/torrc.1
    rm -rf /etc/tor/torrc.2
    rm -rf /etc/tor/torrc.3
    rm -rf /etc/tor/torrc.4
    rm -rf /etc/tor/torrc.5
    rm -rf /etc/dnsmasq.conf
    cp /etc/resolv.conf_OLD /etc/resolv.conf
    cp haproxy.cfg_OLD ./haproxy.cfg

    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -t mangle -F
    iptables -t mangle -X
    iptables -t raw -F
    iptables -t raw -X

    kill -9 $(pgrep -fi dnsmasq)
    kill -9 $(pgrep -fi haproxy)
    kill -9 $(pgrep -fi privoxy)
    kill -9 $(pgrep -fi tor)
fi