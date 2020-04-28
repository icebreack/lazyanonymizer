#!/usr/bin/env bash

if [ "$1" == "start" ]; then


    mkdir -p /tmp/tor/9001
    touch /tmp/tor/9001/torrc
    echo "SocksPort 9001" >> /tmp/tor/9001/torrc
    echo "ControlPort 9091" >> /tmp/tor/9001/torrc
    echo "DNSPort 9053" >> /tmp/tor/9001/torrc
    echo "DataDirectory /tmp/tor/9000" >> /tmp/tor/9001/torrc
    echo "AutomapHostsOnResolve 1" >> /tmp/tor/9001/torrc
    echo "AutomapHostsSuffixes .exit,.onion" >> /tmp/tor/9001/torrc
    echo "Log debug file /tmp/tor/9001/debug.log" >> /tmp/tor/9001/torrc

    mkdir -p /tmp/tor/9002
    touch /tmp/tor/9002/torrc
    echo "SocksPort 9002" >> /tmp/tor/9002/torrc
    echo "ControlPort 9092" >> /tmp/tor/9002/torrc
    echo "DataDirectory /tmp/tor/9002" >> /tmp/tor/9002/torrc
    echo "Log debug file /tmp/tor/9002/debug.log" >> /tmp/tor/9002/torrc

    mkdir -p /tmp/tor/9003
    touch /tmp/tor/9003/torrc
    echo "SocksPort 9003" >> /tmp/tor/9003/torrc
    echo "ControlPort 9093" >> /tmp/tor/9003/torrc
    echo "DataDirectory /tmp/tor/9003" >> /tmp/tor/9003/torrc
    echo "Log debug file /tmp/tor/9003/debug.log" >> /tmp/tor/9003/torrc

    mkdir -p /tmp/tor/9004
    touch /tmp/tor/9004/torrc
    echo "SocksPort 9004" >> /tmp/tor/9004/torrc
    echo "ControlPort 9094" >> /tmp/tor/9004/torrc
    echo "DataDirectory /tmp/tor/9004" >> /tmp/tor/9004/torrc
    echo "Log debug file /tmp/tor/9004/debug.log" >> /tmp/tor/9004/torrc

    mkdir -p /tmp/tor/9005
    touch /tmp/tor/9005/torrc
    echo "SocksPort 9005" >> /tmp/tor/9005/torrc
    echo "ControlPort 9095" >> /tmp/tor/9005/torrc
    echo "DataDirectory /tmp/tor/9005" >> /tmp/tor/9005/torrc
    echo "Log debug file /tmp/tor/9005/debug.log" >> /tmp/tor/9005/torrc


    sudo -u debian-tor tor -f /tmp/tor/9001/torrc --RunAsDaemon 1 --CookieAuthentication 0 --SocksBindAddress 127.0.0.1 --NewCircuitPeriod 15 --MaxCircuitDirtiness 15 --NumEntryGuards 8 --CircuitBuildTimeout 5 --ExitRelay 0 --RefuseUnknownExits 0 --ClientOnly 1 --StrictNodes 1 --AllowSingleHopCircuits 1
    sudo -u debian-tor tor -f /tmp/tor/9002/torrc --RunAsDaemon 1 --CookieAuthentication 0 --SocksBindAddress 127.0.0.1 --NewCircuitPeriod 15 --MaxCircuitDirtiness 15 --NumEntryGuards 8 --CircuitBuildTimeout 5 --ExitRelay 0 --RefuseUnknownExits 0 --ClientOnly 1 --StrictNodes 1 --AllowSingleHopCircuits 1
    sudo -u debian-tor tor -f /tmp/tor/9003/torrc --RunAsDaemon 1 --CookieAuthentication 0 --SocksBindAddress 127.0.0.1 --NewCircuitPeriod 15 --MaxCircuitDirtiness 15 --NumEntryGuards 8 --CircuitBuildTimeout 5 --ExitRelay 0 --RefuseUnknownExits 0 --ClientOnly 1 --StrictNodes 1 --AllowSingleHopCircuits 1
    sudo -u debian-tor tor -f /tmp/tor/9004/torrc--RunAsDaemon 1 --CookieAuthentication 0 --SocksBindAddress 127.0.0.1 --NewCircuitPeriod 15 --MaxCircuitDirtiness 15 --NumEntryGuards 8 --CircuitBuildTimeout 5 --ExitRelay 0 --RefuseUnknownExits 0 --ClientOnly 1 --StrictNodes 1 --AllowSingleHopCircuits 1
    sudo -u debian-tor tor -f /tmp/tor/9005/torrc --RunAsDaemon 1 --CookieAuthentication 0 --SocksBindAddress 127.0.0.1 --NewCircuitPeriod 15 --MaxCircuitDirtiness 15 --NumEntryGuards 8 --CircuitBuildTimeout 5 --ExitRelay 0 --RefuseUnknownExits 0 --ClientOnly 1 --StrictNodes 1 --AllowSingleHopCircuits 1

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
    echo "server            socks-process-9002 127.0.0.1:9002 check fall 3 rise 2" >> ./haproxy.cfg
    echo "server            socks-process-9003 127.0.0.1:9003 check fall 3 rise 2" >> ./haproxy.cfg
    echo "server            socks-process-9004 127.0.0.1:9004 check fall 3 rise 2" >> ./haproxy.cfg
    echo "server            socks-process-9005 127.0.0.1:9005 check fall 3 rise 2" >> ./haproxy.cfg

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
