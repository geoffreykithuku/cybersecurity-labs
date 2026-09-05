## Introduction

This lab documents reconnaissance performed from a Kali VM (192.168.122.230) against a Metasploitable2 VM (192.168.122.116). It covers host discovery, TCP and UDP port/service enumeration, OS and service fingerprinting with Nmap, basic script-based enumeration, and web fingerprinting with WhatWeb. Terminal outputs and raw evidence are preserved verbatim later in the report.

I used ip addr to find the ip address and interface of my vm. which was on inet/ 192.168.122.230/24

the metasploitable ip was 192.168.122.116 (ifconfig command). Both are on the same virtual network.

I ran the ping -c 4 command on both vms while targeting the ip address of the other vm. I got a response back which meant that the two vms could communicate with each other.

I used nmap -sn to discover live hosts on the network. Then nmap 192.168.122.116 to see open ports on the metasplotable2

i passed the -sV flag to nmap to get the service versions and got this response

```bash
$ nmap -sV 192.168.122.116
Starting Nmap 7.99 ( https://nmap.org ) at 2026-09-04 10:18 -0400
Nmap scan report for 192.168.122.116
Host is up (0.012s latency).
Not shown: 977 closed tcp ports (reset)
PORT     STATE SERVICE     VERSION
21/tcp   open  ftp         vsftpd 2.3.4
22/tcp   open  ssh         OpenSSH 4.7p1 Debian 8ubuntu1 (protocol 2.0)
23/tcp   open  telnet      Linux telnetd
25/tcp   open  smtp        Postfix smtpd
53/tcp   open  domain      ISC BIND 9.4.2
80/tcp   open  http        Apache httpd 2.2.8 ((Ubuntu) DAV/2)
111/tcp  open  rpcbind     2 (RPC #100000)
139/tcp  open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp  open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
512/tcp  open  exec?
513/tcp  open  login
514/tcp  open  shell?
1099/tcp open  java-rmi    GNU Classpath grmiregistry
1524/tcp open  bindshell   Metasploitable root shell
2049/tcp open  nfs         2-4 (RPC #100003)
2121/tcp open  ftp         ProFTPD 1.3.1
```

by passing --version-intensity , nmap performs a more rigorous check

I detected the target os by passing -O to the nmap command

```bash
└─$ sudo nmap -O 192.168.122.116
[sudo] password for kali:
Starting Nmap 7.99 ( https://nmap.org ) at 2026-09-04 11:06 -0400
Nmap scan report for 192.168.122.116
Host is up (0.0014s latency).
Not shown: 977 closed tcp ports (reset)
PORT     STATE SERVICE
21/tcp   open  ftp
22/tcp   open  ssh
23/tcp   open  telnet
25/tcp   open  smtp
53/tcp   open  domain
80/tcp   open  http
111/tcp  open  rpcbind
139/tcp  open  netbios-ssn
445/tcp  open  microsoft-ds
512/tcp  open  exec
513/tcp  open  login
514/tcp  open  shell
1099/tcp open  rmiregistry
1524/tcp open  ingreslock
2049/tcp open  nfs
2121/tcp open  ccproxy-ftp
3306/tcp open  mysql
5432/tcp open  postgresql
5900/tcp open  vnc
6000/tcp open  X11
6667/tcp open  irc
8009/tcp open  ajp13
8180/tcp open  unknown
MAC Address: 52:54:00:3A:16:3C (QEMU virtual NIC)
Device type: general purpose
Running: Linux 2.6.X
OS CPE: cpe:/o:linux:linux_kernel:2.6
OS details: Linux 2.6.9 - 2.6.33
Network Distance: 1 hop

OS detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 2.28 seconds
```

the nmap -A does a more agressive scan by combining OS and version detection, running NSE scripts and traceroute where applicable

```bash
┌──(kali㉿kali)-[~]
└─$ sudo nmap -A 192.168.122.116
Starting Nmap 7.99 ( https://nmap.org ) at 2026-09-04 11:16 -0400
Nmap scan report for 192.168.122.116
Host is up (0.0014s latency).
Not shown: 977 closed tcp ports (reset)
PORT     STATE SERVICE     VERSION
21/tcp   open  ftp         vsftpd 2.3.4
|_ftp-anon: Anonymous FTP login allowed (FTP code 230)
| ftp-syst:
|   STAT:
| FTP server status:
|      Connected to 192.168.122.230
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      vsFTPd 2.3.4 - secure, fast, stable
|_End of status
22/tcp   open  ssh         OpenSSH 4.7p1 Debian 8ubuntu1 (protocol 2.0)
| ssh-hostkey:
|   1024 60:0f:cf:e1:c0:5f:6a:74:d6:90:24:fa:c4:d5:6c:cd (DSA)
|_  2048 56:56:24:0f:21:1d:de:a7:2b:ae:61:b1:24:3d:e8:f3 (RSA)
23/tcp   open  telnet      Linux telnetd
25/tcp   open  smtp        Postfix smtpd
|_smtp-commands: metasploitable.localdomain, PIPELINING, SIZE 10240000, VRFY, ETRN, STARTTLS, ENHANCEDSTATUSCODES, 8BITMIME, DSN
|_ssl-date: 2026-09-04T15:17:43+00:00; -1s from scanner time.
| sslv2:
|   SSLv2 supported
|   ciphers:
|     SSL2_RC4_128_WITH_MD5
|     SSL2_RC2_128_CBC_EXPORT40_WITH_MD5
|     SSL2_RC4_128_EXPORT40_WITH_MD5
|     SSL2_DES_64_CBC_WITH_MD5
|     SSL2_RC2_128_CBC_WITH_MD5
|_    SSL2_DES_192_EDE3_CBC_WITH_MD5
| ssl-cert: Subject: commonName=ubuntu804-base.localdomain/organizationName=OCOSA/stateOrProvinceName=There is no such thing outside US/countryName=XX
| Not valid before: 2010-03-17T14:07:45
|_Not valid after:  2010-04-16T14:07:45
53/tcp   open  domain      ISC BIND 9.4.2
| dns-nsid:
|_  bind.version: 9.4.2
80/tcp   open  http        Apache httpd 2.2.8 ((Ubuntu) DAV/2)
|_http-title: Metasploitable2 - Linux
|_http-server-header: Apache/2.2.8 (Ubuntu) DAV/2
111/tcp  open  rpcbind     2 (RPC #100000)
| rpcinfo:
|   program version    port/proto  service
|   100000  2            111/tcp   rpcbind
|   100000  2            111/udp   rpcbind
|   100003  2,3,4       2049/tcp   nfs
|   100003  2,3,4       2049/udp   nfs
|   100005  1,2,3      38940/tcp   mountd
|   100005  1,2,3      48929/udp   mountd
|   100021  1,3,4      39505/udp   nlockmgr
|   100021  1,3,4      44964/tcp   nlockmgr
|   100024  1          39578/tcp   status
|_  100024  1          54504/udp   status
139/tcp  open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp  open  netbios-ssn Samba smbd 3.0.20-Debian (workgroup: WORKGROUP)
512/tcp  open  exec?
513/tcp  open  login       OpenBSD or Solaris rlogind
514/tcp  open  shell?
| fingerprint-strings:
|   NULL:
|_    Couldn't get address for your host (kali)
1099/tcp open  java-rmi    GNU Classpath grmiregistry
1524/tcp open  bindshell   Metasploitable root shell
2049/tcp open  nfs         2-4 (RPC #100003)
2121/tcp open  ftp         ProFTPD 1.3.1
3306/tcp open  mysql       MySQL 5.0.51a-3ubuntu5
| mysql-info:
|   Protocol: 10
|   Version: 5.0.51a-3ubuntu5
|   Thread ID: 10
|   Capabilities flags: 43564
|   Some Capabilities: LongColumnFlag, SupportsTransactions, Support41Auth, SupportsCompression, Speaks41ProtocolNew, ConnectWithDatabase, SwitchToSSLAfterHandshake
|   Status: Autocommit
|_  Salt: yH8"=NO%fUW5D3qc|d`5
5432/tcp open  postgresql  PostgreSQL DB 8.3.0 - 8.3.7
|_ssl-date: 2026-09-04T15:17:43+00:00; -1s from scanner time.
| ssl-cert: Subject: commonName=ubuntu804-base.localdomain/organizationName=OCOSA/stateOrProvinceName=There is no such thing outside US/countryName=XX
| Not valid before: 2010-03-17T14:07:45
|_Not valid after:  2010-04-16T14:07:45
5900/tcp open  vnc         VNC (protocol 3.3)
| vnc-info:
|   Protocol version: 3.3
|   Security types:
|_    VNC Authentication (2)
6000/tcp open  X11         (access denied)
6667/tcp open  irc         UnrealIRCd
| irc-info:
|   users: 1
|   servers: 1
|   lusers: 1
|   lservers: 0
|   server: irc.Metasploitable.LAN
|   version: Unreal3.2.8.1. irc.Metasploitable.LAN
|   uptime: 0 days, 2:34:32
|   source ident: nmap
|   source host: Test-B025CB0A
|_  error: Closing Link: zgvezpzol[kali] (Quit: zgvezpzol)
8009/tcp open  ajp13       Apache Jserv (Protocol v1.3)
|_ajp-methods: Failed to get a valid response for the OPTION request
8180/tcp open  http        Apache Tomcat/Coyote JSP engine 1.1
|_http-server-header: Apache-Coyote/1.1
|_http-favicon: Apache Tomcat
|_http-title: Apache Tomcat/5.5
1 service unrecognized despite returning data. If you know the service/version, please submit the following fingerprint at https://nmap.org/cgi-bin/submit.cgi?new-service :
SF-Port514-TCP:V=7.99%I=7%D=9/4%Time=6A9AE0CD%P=x86_64-pc-linux-gnu%r(NULL
SF:,2B,"\x01Couldn't\x20get\x20address\x20for\x20your\x20host\x20\(kali\)\
SF:n");
MAC Address: 52:54:00:3A:16:3C (QEMU virtual NIC)
Device type: general purpose
Running: Linux 2.6.X
OS CPE: cpe:/o:linux:linux_kernel:2.6
OS details: Linux 2.6.9 - 2.6.33
Network Distance: 1 hop
Service Info: Hosts:  metasploitable.localdomain, irc.Metasploitable.LAN; OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Host script results:
|_clock-skew: mean: 59m59s, deviation: 2h00m00s, median: -1s
|_smb2-time: Protocol negotiation failed (SMB2)
| smb-os-discovery:
|   OS: Unix (Samba 3.0.20-Debian)
|   Computer name: metasploitable
|   NetBIOS computer name:
|   Domain name: localdomain
|   FQDN: metasploitable.localdomain
|_  System time: 2026-09-04T11:17:35-04:00
|_nbstat: NetBIOS name: METASPLOITABLE, NetBIOS user: <unknown>, NetBIOS MAC: <unknown> (unknown)
| smb-security-mode:
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)

TRACEROUTE
HOP RTT     ADDRESS
1   1.36 ms 192.168.122.116

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 76.45 seconds
```

compared to the default scan, the agressive scan returns more data.

sudo nmap -p- 192.168.122.116 , does a full port scan for all tcp ports

```bash
┌──(kali㉿kali)-[~]
└─$ sudo nmap -p- 192.168.122.116
Starting Nmap 7.99 ( https://nmap.org ) at 2026-09-04 11:22 -0400
Nmap scan report for 192.168.122.116
Host is up (0.0096s latency).
Not shown: 65505 closed tcp ports (reset)
PORT      STATE SERVICE
21/tcp    open  ftp
22/tcp    open  ssh
23/tcp    open  telnet
25/tcp    open  smtp
53/tcp    open  domain
80/tcp    open  http
111/tcp   open  rpcbind
139/tcp   open  netbios-ssn
445/tcp   open  microsoft-ds
512/tcp   open  exec
513/tcp   open  login
514/tcp   open  shell
1099/tcp  open  rmiregistry
1524/tcp  open  ingreslock
2049/tcp  open  nfs
2121/tcp  open  ccproxy-ftp
3306/tcp  open  mysql
3632/tcp  open  distccd
5432/tcp  open  postgresql
5900/tcp  open  vnc
6000/tcp  open  X11
6667/tcp  open  irc
6697/tcp  open  ircs-u
8009/tcp  open  ajp13
8180/tcp  open  unknown
8787/tcp  open  msgsrvr
36930/tcp open  unknown
38940/tcp open  unknown
39578/tcp open  unknown
44964/tcp open  unknown
MAC Address: 52:54:00:3A:16:3C (QEMU virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 17.87 seconds
```

```bash
┌──(kali㉿kali)-[~]
└─$ sudo nmap -p- -sV 192.168.122.116
Starting Nmap 7.99 ( https://nmap.org ) at 2026-09-04 11:25 -0400
Nmap scan report for 192.168.122.116
Host is up (0.0065s latency).
Not shown: 65505 closed tcp ports (reset)
PORT      STATE SERVICE     VERSION
21/tcp    open  ftp         vsftpd 2.3.4
22/tcp    open  ssh         OpenSSH 4.7p1 Debian 8ubuntu1 (protocol 2.0)
23/tcp    open  telnet      Linux telnetd
25/tcp    open  smtp        Postfix smtpd
53/tcp    open  domain      ISC BIND 9.4.2
80/tcp    open  http        Apache httpd 2.2.8 ((Ubuntu) DAV/2)
111/tcp   open  rpcbind     2 (RPC #100000)
139/tcp   open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp   open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
512/tcp   open  exec?
513/tcp   open  login       OpenBSD or Solaris rlogind
514/tcp   open  shell?
1099/tcp  open  java-rmi    GNU Classpath grmiregistry
1524/tcp  open  bindshell   Metasploitable root shell
2049/tcp  open  nfs         2-4 (RPC #100003)
2121/tcp  open  ftp         ProFTPD 1.3.1
3306/tcp  open  mysql       MySQL 5.0.51a-3ubuntu5
3632/tcp  open  distccd     distccd v1 ((GNU) 4.2.4 (Ubuntu 4.2.4-1ubuntu4))
5432/tcp  open  postgresql  PostgreSQL DB 8.3.0 - 8.3.7
5900/tcp  open  vnc         VNC (protocol 3.3)
6000/tcp  open  X11         (access denied)
6667/tcp  open  irc         UnrealIRCd
6697/tcp  open  irc         UnrealIRCd
8009/tcp  open  ajp13       Apache Jserv (Protocol v1.3)
8180/tcp  open  http        Apache Tomcat/Coyote JSP engine 1.1
8787/tcp  open  drb         Ruby DRb RMI (Ruby 1.8; path /usr/lib/ruby/1.8/drb)
36930/tcp open  java-rmi    GNU Classpath grmiregistry
38940/tcp open  mountd      1-3 (RPC #100005)
39578/tcp open  status      1 (RPC #100024)
44964/tcp open  nlockmgr    1-4 (RPC #100021)
1 service unrecognized despite returning data. If you know the service/version, please submit the following fingerprint at https://nmap.org/cgi-bin/submit.cgi?new-service :
SF-Port514-TCP:V=7.99%I=7%D=9/4%Time=6A9AE2FC%P=x86_64-pc-linux-gnu%r(NULL
SF:,2B,"\x01Couldn't\x20get\x20address\x20for\x20your\x20host\x20\(kali\)\
SF:n");
MAC Address: 52:54:00:3A:16:3C (QEMU virtual NIC)
Service Info: Hosts:  metasploitable.localdomain, irc.Metasploitable.LAN; OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 145.14 seconds
```

local lab scans can be accelarated by passing the -T4 flag to the nmap command

```bash
──(kali㉿kali)-[~]
└─$ sudo nmap -p- -T4 192.168.122.116
Starting Nmap 7.99 ( https://nmap.org ) at 2026-09-04 11:30 -0400
Nmap scan report for 192.168.122.116
Host is up (0.0031s latency).
Not shown: 65505 closed tcp ports (reset)
PORT      STATE SERVICE
21/tcp    open  ftp
22/tcp    open  ssh
23/tcp    open  telnet
25/tcp    open  smtp
53/tcp    open  domain
80/tcp    open  http
111/tcp   open  rpcbind
139/tcp   open  netbios-ssn
445/tcp   open  microsoft-ds
512/tcp   open  exec
513/tcp   open  login
514/tcp   open  shell
1099/tcp  open  rmiregistry
1524/tcp  open  ingreslock
2049/tcp  open  nfs
2121/tcp  open  ccproxy-ftp
3306/tcp  open  mysql
3632/tcp  open  distccd
5432/tcp  open  postgresql
5900/tcp  open  vnc
6000/tcp  open  X11
6667/tcp  open  irc
6697/tcp  open  ircs-u
8009/tcp  open  ajp13
8180/tcp  open  unknown
8787/tcp  open  msgsrvr
36930/tcp open  unknown
38940/tcp open  unknown
39578/tcp open  unknown
44964/tcp open  unknown
MAC Address: 52:54:00:3A:16:3C (QEMU virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 16.95 seconds
```

Also, someone can specify the ports that they want to scan by passing the to the nmap -p- command. Also this can be done by specifying the port range

```bash
┌──(kali㉿kali)-[~]
└─$ nmap -p 21,22,23,25,80,139,445 192.168.122.116
Starting Nmap 7.99 ( https://nmap.org ) at 2026-09-04 11:42 -0400
Nmap scan report for 192.168.122.116
Host is up (0.0014s latency).

PORT    STATE SERVICE
21/tcp  open  ftp
22/tcp  open  ssh
23/tcp  open  telnet
25/tcp  open  smtp
80/tcp  open  http
139/tcp open  netbios-ssn
445/tcp open  microsoft-ds
MAC Address: 52:54:00:3A:16:3C (QEMU virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 0.71 seconds
```

```bash
┌──(kali㉿kali)-[~]
└─$ nmap -p 21-445 192.168.122.116
Starting Nmap 7.99 ( https://nmap.org ) at 2026-09-04 12:32 -0400
Nmap scan report for 192.168.122.116
Host is up (0.015s latency).
Not shown: 416 closed tcp ports (reset)
PORT    STATE SERVICE
21/tcp  open  ftp
22/tcp  open  ssh
23/tcp  open  telnet
25/tcp  open  smtp
53/tcp  open  domain
80/tcp  open  http
111/tcp open  rpcbind
139/tcp open  netbios-ssn
445/tcp open  microsoft-ds
MAC Address: 52:54:00:3A:16:3C (QEMU virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 1.20 seconds
```

scanning for UDP services

by putting the --top-ports 20

it does a smaller scan

```bash
┌──(kali㉿kali)-[~]
└─$ nmap -sU 192.168.122.116
Starting Nmap 7.99 ( https://nmap.org ) at 2026-09-04 12:33 -0400
```

```bash
┌──(kali㉿kali)-[~]
└─$ sudo nmap -sU --top-ports 20 -sV 192.168.122.116
[sudo] password for kali:
Starting Nmap 7.99 ( https://nmap.org ) at 2026-09-04 12:42 -0400
Nmap scan report for 192.168.122.116
Host is up (0.00099s latency).

PORT      STATE         SERVICE      VERSION
53/udp    open          domain       ISC BIND 9.4.2
67/udp    closed        dhcps
68/udp    open|filtered dhcpc
69/udp    open|filtered tftp
123/udp   closed        ntp
135/udp   closed        msrpc
137/udp   open          netbios-ns   Microsoft Windows netbios-ns (workgroup: WORKGROUP)
138/udp   open|filtered netbios-dgm
139/udp   closed        netbios-ssn
161/udp   closed        snmp
162/udp   closed        snmptrap
445/udp   closed        microsoft-ds
500/udp   closed        isakmp
514/udp   closed        syslog
520/udp   closed        route
631/udp   closed        ipp
1434/udp  closed        ms-sql-m
1900/udp  closed        upnp
4500/udp  closed        nat-t-ike
49152/udp closed        unknown
MAC Address: 52:54:00:3A:16:3C (QEMU virtual NIC)
Service Info: Host: METASPLOITABLE; OS: Windows; CPE: cpe:/o:microsoft:windows

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 123.78 seconds
```

open state - accepting connections
closed state - host is reachable but nothing is listening on the port
filtered - nmap cannot determine the state because filtering blocks probe

-sC shows the scripts

```bash
┌──(kali㉿kali)-[~]
└─$ sudo nmap -sC -sV 192.168.122.116
[sudo] password for kali:
Starting Nmap 7.99 ( https://nmap.org ) at 2026-09-04 13:08 -0400
Nmap scan report for 192.168.122.116
Host is up (0.17s latency).
Not shown: 977 closed tcp ports (reset)
PORT     STATE SERVICE     VERSION
21/tcp   open  ftp         vsftpd 2.3.4
| ftp-syst:
|   STAT:
| FTP server status:
|      Connected to 192.168.122.230
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      vsFTPd 2.3.4 - secure, fast, stable
|_End of status
|_ftp-anon: Anonymous FTP login allowed (FTP code 230)
22/tcp   open  ssh         OpenSSH 4.7p1 Debian 8ubuntu1 (protocol 2.0)
| ssh-hostkey:
|   1024 60:0f:cf:e1:c0:5f:6a:74:d6:90:24:fa:c4:d5:6c:cd (DSA)
|_  2048 56:56:24:0f:21:1d:de:a7:2b:ae:61:b1:24:3d:e8:f3 (RSA)
23/tcp   open  telnet      Linux telnetd
25/tcp   open  smtp        Postfix smtpd
|_ssl-date: 2026-09-04T17:09:36+00:00; -1s from scanner time.
|_smtp-commands: metasploitable.localdomain, PIPELINING, SIZE 10240000, VRFY, ETRN, STARTTLS, ENHANCEDSTATUSCODES, 8BITMIME, DSN
| ssl-cert: Subject: commonName=ubuntu804-base.localdomain/organizationName=OCOSA/stateOrProvinceName=There is no such thing outside US/countryName=XX
| Not valid before: 2010-03-17T14:07:45
|_Not valid after:  2010-04-16T14:07:45
| sslv2:
|   SSLv2 supported
|   ciphers:
|     SSL2_DES_64_CBC_WITH_MD5
|     SSL2_RC4_128_WITH_MD5
|     SSL2_RC2_128_CBC_EXPORT40_WITH_MD5
|     SSL2_DES_192_EDE3_CBC_WITH_MD5
|     SSL2_RC2_128_CBC_WITH_MD5
|_    SSL2_RC4_128_EXPORT40_WITH_MD5
53/tcp   open  domain      ISC BIND 9.4.2
| dns-nsid:
|_  bind.version: 9.4.2
80/tcp   open  http        Apache httpd 2.2.8 ((Ubuntu) DAV/2)
|_http-title: Metasploitable2 - Linux
|_http-server-header: Apache/2.2.8 (Ubuntu) DAV/2
111/tcp  open  rpcbind     2 (RPC #100000)
| rpcinfo:
|   program version    port/proto  service
|   100005  1,2,3      38940/tcp   mountd
|   100005  1,2,3      48929/udp   mountd
|   100021  1,3,4      39505/udp   nlockmgr
|_  100021  1,3,4      44964/tcp   nlockmgr
139/tcp  open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp  open  netbios-ssn Samba smbd 3.0.20-Debian (workgroup: WORKGROUP)
512/tcp  open  exec?
513/tcp  open  login
514/tcp  open  shell?
| fingerprint-strings:
|   NULL:
|_    Couldn't get address for your host (kali)
1099/tcp open  java-rmi    GNU Classpath grmiregistry
1524/tcp open  bindshell   Metasploitable root shell
2049/tcp open  nfs         2-4 (RPC #100003)
2121/tcp open  ftp         ProFTPD 1.3.1
3306/tcp open  mysql       MySQL 5.0.51a-3ubuntu5
| mysql-info:
|   Protocol: 10
|   Version: 5.0.51a-3ubuntu5
|   Thread ID: 23
|   Capabilities flags: 43564
|   Some Capabilities: LongColumnFlag, SupportsCompression, Support41Auth, ConnectWithDatabase, SupportsTransactions, SwitchToSSLAfterHandshake, Speaks41ProtocolNew
|   Status: Autocommit
|_  Salt: 2IZi$p*~]9C&3j@@_<P]
5432/tcp open  postgresql  PostgreSQL DB 8.3.0 - 8.3.7
|_ssl-date: 2026-09-04T17:09:36+00:00; -1s from scanner time.
| ssl-cert: Subject: commonName=ubuntu804-base.localdomain/organizationName=OCOSA/stateOrProvinceName=There is no such thing outside US/countryName=XX
| Not valid before: 2010-03-17T14:07:45
|_Not valid after:  2010-04-16T14:07:45
5900/tcp open  vnc         VNC (protocol 3.3)
| vnc-info:
|   Protocol version: 3.3
|   Security types:
|_    VNC Authentication (2)
6000/tcp open  X11         (access denied)
6667/tcp open  irc         UnrealIRCd
8009/tcp open  ajp13       Apache Jserv (Protocol v1.3)
|_ajp-methods: Failed to get a valid response for the OPTION request
8180/tcp open  http        Apache Tomcat/Coyote JSP engine 1.1
|_http-favicon: Apache Tomcat
|_http-server-header: Apache-Coyote/1.1
|_http-title: Apache Tomcat/5.5
1 service unrecognized despite returning data. If you know the service/version, please submit the following fingerprint at https://nmap.org/cgi-bin/submit.cgi?new-service :
SF-Port514-TCP:V=7.99%I=7%D=9/4%Time=6A9AFB06%P=x86_64-pc-linux-gnu%r(NULL
SF:,2B,"\x01Couldn't\x20get\x20address\x20for\x20your\x20host\x20\(kali\)\
SF:n");
MAC Address: 52:54:00:3A:16:3C (QEMU virtual NIC)
Service Info: Hosts:  metasploitable.localdomain, irc.Metasploitable.LAN; OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Host script results:
| smb-os-discovery:
|   OS: Unix (Samba 3.0.20-Debian)
|   Computer name: metasploitable
|   NetBIOS computer name:
|   Domain name: localdomain
|   FQDN: metasploitable.localdomain
|_  System time: 2026-09-04T13:09:26-04:00
|_smb2-time: Protocol negotiation failed (SMB2)
| smb-security-mode:
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
|_clock-skew: mean: 59m58s, deviation: 2h00m00s, median: -1s
|_nbstat: NetBIOS name: METASPLOITABLE, NetBIOS user: <unknown>, NetBIOS MAC: <unknown> (unknown)

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 78.13 seconds
```

from the terminal results, the two scripts I found are:

- anonymous ftp login allowed - \_ftp-anon: Anonymous FTP login allowed (FTP code 230)
- smb security misconfiguration - message_signing: disabled (dangerous, but default)

I learnt how to read title of the lab webpage by running nmap -p 80 --script http-title 192.168.122.116

```bash
┌──(kali㉿kali)-[~]
└─$ nmap -p 80 --script http-title 192.168.122.116
Starting Nmap 7.99 ( https://nmap.org ) at 2026-09-04 16:21 -0400
Nmap scan report for 192.168.122.116
Host is up (0.00069s latency).

PORT   STATE SERVICE
80/tcp open  http
|_http-title: Metasploitable2 - Linux
MAC Address: 52:54:00:3A:16:3C (QEMU virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 0.77 seconds
```

the headers can be read by adding the --http-headers flag

```bash
└─$ nmap -p 80 --script http-headers 192.168.122.116
Starting Nmap 7.99 ( https://nmap.org ) at 2026-09-04 16:23 -0400
Nmap scan report for 192.168.122.116
Host is up (0.00073s latency).

PORT   STATE SERVICE
80/tcp open  http
| http-headers:
|   Date: Fri, 04 Sep 2026 20:23:50 GMT
|   Server: Apache/2.2.8 (Ubuntu) DAV/2
|   X-Powered-By: PHP/5.2.4-2ubuntu5.10
|   Connection: close
|   Content-Type: text/html
|
|_  (Request type: HEAD)
MAC Address: 52:54:00:3A:16:3C (QEMU virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 0.78 seconds
```

smb protocols

```bash
└─$ nmap -p 139,445 --script smb-protocols 192.168.122.116
Starting Nmap 7.99 ( https://nmap.org ) at 2026-09-04 16:25 -0400
Nmap scan report for 192.168.122.116
Host is up (0.00066s latency).

PORT    STATE SERVICE
139/tcp open  netbios-ssn
445/tcp open  microsoft-ds
MAC Address: 52:54:00:3A:16:3C (QEMU virtual NIC)

Host script results:
| smb-protocols:
|   dialects:
|_    NT LM 0.12 (SMBv1) [dangerous, but default]

Nmap done: 1 IP address (1 host up) scanned in 0.76 seconds
```

ssh server identity fingerprints

nmap -p 22 --script ssh-hostkey 192.168.122.116

I found these to algos

DSA
RSA

banner scripts: nmap -p 21 -sV --script banner 192.168.122.116

```
|_banner: 220 (vsFTPd 2.3.4)
```

the banner shows the welcome message shown to connecting clients

Manual HTTP confirmation

curl -I http://192.168.122.116

the status code returned is 200 OK and the header: X-Powered-By: PHP/5.2.4-2ubuntu5.10

whatweb fingerprinting

whatweb http://192.168.122.116

```bash
┌──(kali㉿kali)-[~]
└─$ whatweb http://192.168.122.116
http://192.168.122.116 [200 OK] Apache[2.2.8], Country[RESERVED][ZZ], HTTPServer[Ubuntu Linux][Apache/2.2.8 (Ubuntu) DAV/2], IP[192.168.122.116], PHP[5.2.4-2ubuntu5.10], Title[Metasploitable2 - Linux], WebDAV[2], X-Powered-By[PHP/5.2.4-2ubuntu5.10]
```

the technologies discovered as seen form the outpu

Apache - an outdated version with known vulnerabilities
Old PHP version that hit end of life hence vulnerable to exploits
WebDAV enabled allows remote code execution and other exploits if misconfigured

the verbose output of whatweb can be fetched by passing the -v flag. It returns detailed descriptions of the technologies used, and more headers

The whatweb tool output can be modified using the -a aggression flag which you can specify either agression level 1 - lightest, 4 - more aggressive, etc

```bash
┌──(kali㉿kali)-[~]
└─$ whatweb -a 1 http://192.168.122.116
http://192.168.122.116 [200 OK] Apache[2.2.8], Country[RESERVED][ZZ], HTTPServer[Ubuntu Linux][Apache/2.2.8 (Ubuntu) DAV/2], IP[192.168.122.116], PHP[5.2.4-2ubuntu5.10], Title[Metasploitable2 - Linux], WebDAV[2], X-Powered-By[PHP/5.2.4-2ubuntu5.10]
```

```bash
┌──(kali㉿kali)-[~]
└─$ whatweb -a 3 http://192.168.122.116
http://192.168.122.116 [200 OK] Apache[2.2.8], Country[RESERVED][ZZ], HTTPServer[Ubuntu Linux][Apache/2.2.8 (Ubuntu) DAV/2], IP[192.168.122.116], PHP[5,5.2.4-2ubuntu5.10], Title[Metasploitable2 - Linux], WebDAV[2], X-Powered-By[PHP/5.2.4-2ubuntu5.10]
```

```bash
┌──(kali㉿kali)-[~]
└─$ whatweb -a 3 -v http://192.168.122.116
WhatWeb report for http://192.168.122.116
Status    : 200 OK
Title     : Metasploitable2 - Linux
IP        : 192.168.122.116
Country   : RESERVED, ZZ

Summary   : Apache[2.2.8], HTTPServer[Ubuntu Linux][Apache/2.2.8 (Ubuntu) DAV/2], PHP[5,5.2.4-2ubuntu5.10], WebDAV[2], X-Powered-By[PHP/5.2.4-2ubuntu5.10]

Detected Plugins:
[ Apache ]
        The Apache HTTP Server Project is an effort to develop and
        maintain an open-source HTTP server for modern operating
        systems including UNIX and Windows NT. The goal of this
        project is to provide a secure, efficient and extensible
        server that provides HTTP services in sync with the current
        HTTP standards.

        Version      : 2.2.8 (from HTTP Server Header)
        Google Dorks: (3)
        Website     : http://httpd.apache.org/

[ HTTPServer ]
        HTTP server header string. This plugin also attempts to
        identify the operating system from the server header.

        OS           : Ubuntu Linux
        String       : Apache/2.2.8 (Ubuntu) DAV/2 (from server string)

[ PHP ]
        PHP is a widely-used general-purpose scripting language
        that is especially suited for Web development and can be
        embedded into HTML. This plugin identifies PHP errors,
        modules and versions and extracts the local file path and
        username if present.

        Version      : 5.2.4-2ubuntu5.10
        Version      : 5
        Google Dorks: (3)
        Website     : http://www.php.net/

[ WebDAV ]
        Web-based Distributed Authoring and Versioning (WebDAV) is
        a set of methods based on the Hypertext Transfer Protocol
        (HTTP) that facilitates collaboration between users in
        editing and managing documents and files stored on World
        Wide Web servers. - More Info:
        http://en.wikipedia.org/wiki/WebDAV

        Version      : 2

[ X-Powered-By ]
        X-Powered-By HTTP header

        String       : PHP/5.2.4-2ubuntu5.10 (from x-powered-by string)

HTTP Headers:
        HTTP/1.1 200 OK
        Date: Sat, 05 Sep 2026 00:25:45 GMT
        Server: Apache/2.2.8 (Ubuntu) DAV/2
        X-Powered-By: PHP/5.2.4-2ubuntu5.10
        Content-Length: 891
        Connection: close
        Content-Type: text/html
```

you can follow a redirect by passing this flag

--follow-redirect=always

for my target scan, no redirects were found

# ==========================================


# Services Table

This table summarizes 10 key ports/services from my lab exploration.

| Port | Protocol | State | Service | Version/Evidence | Command |
|---:|:---:|:---:|:---|:---|:---|
| 21 | tcp | open | ftp | vsftpd 2.3.4 | `nmap -sV 192.168.122.116` |
| 22 | tcp | open | ssh | OpenSSH 4.7p1 Debian 8ubuntu1 | `nmap -sV 192.168.122.116` |
| 23 | tcp | open | telnet | Linux telnetd | `nmap -sV 192.168.122.116` |
| 25 | tcp | open | smtp | Postfix smtpd | `nmap -sV 192.168.122.116` |
| 53 | tcp | open | domain | ISC BIND 9.4.2 | `nmap -sV 192.168.122.116` |
| 80 | tcp | open | http | Apache httpd 2.2.8 (Ubuntu) DAV/2 | `nmap -sV 192.168.122.116` |
| 111 | tcp | open | rpcbind | rpcbind 2 (RPC #100000) | `nmap -sV 192.168.122.116` |
| 139 | tcp | open | netbios-ssn | Samba smbd 3.X - 4.X | `nmap -sV 192.168.122.116` |
| 445 | tcp | open | netbios-ssn | Samba smbd 3.0.20-Debian | `sudo nmap -A 192.168.122.116` |
| 3306 | tcp | open | mysql | MySQL 5.0.51a-3ubuntu5 | `sudo nmap -A 192.168.122.116` |



# ===========================================

Part 8 - Student Questions

1. What is reconnaissance?

- this is the act of gathering relevant info on target machine to help plan an attack

2. What is the difference between host discovery and port scanning?

- host discovery is the process of identifying which hosts are up and running on a network, while port scanning is the process of identifying which ports are open, closed or filtered on a specific host.

3. Explain open, closed and filtered.

- Open - the port is accepting connections and is reachable
- Closed - the port is reachable but nothing is listening on the port
- Filtered - nmap cannot determine the state because filtering blocks probe

4. What does -sV do?

- The -sV option in Nmap enables version detection, which allows Nmap to determine the version of the services running on open ports. This provides more detailed information about the target system, such as the software name and version number, which can be useful for identifying potential vulnerabilities.

5. What does -O do?

- enables OS detection. can be helpful in tailoring attacks to the specific os used

6. Explain what -A combines and why it is noisier.

- the -a performs an aggresive scan that combines OS detection, version detection, script scanning and traceroute. it sends more probes to the target machine and therefore is noisier and more likely to be detected by intrusion detection systems

7. What does -p- mean?

- scans all tcp ports on the target machine

8. Why can UDP scans take longer?

- UDP is connectionless. There is no guarantee that the target will respond to the UDP probe. The scanning machine has to wait for a response or timeout before moving on to the next port

9. What does -sC do?

- The -sC option in Nmap enables the default script scanning, which runs a set of predefined scripts against the target to gather additional information about the services running on open ports. These scripts can provide insights into potential vulnerabilities, misconfigurations, and other useful details about the target system.

10. What information did the HTTP title/headers scripts reveal?

- the title of the webpage, the server type and version, the programming language used (PHP), and the presence of WebDAV. The headers also revealed the date, content length, connection type, and content type of the HTTP response.

11. What did SMB/SSH/FTP enumeration add?

- SMB enumeration revealed the operating system (Unix) and Samba version (3.0.20-Debian), as well as the computer name, domain name, and NetBIOS name. It also showed that message signing was disabled, which is a security risk.

12. What is the difference between Nmap service detection and WhatWeb fingerprinting?

- Nmap service detection (-sV) identifies the services running on open ports and attempts to determine their versions, while WhatWeb fingerprinting analyzes the web server and its technologies (like Apache, PHP, etc.) to provide a detailed profile of the web application. Nmap focuses on network services, while WhatWeb focuses on web technologies.

13. How did WhatWeb levels 1, 3 and 4 differ?

- Level 1 is the lightest scan, providing basic information about the web server and its technologies. Level 3 is more aggressive, gathering more detailed information and potentially identifying additional technologies or configurations. Level 4 is the most aggressive, performing extensive checks and potentially revealing even more details about the web application and its underlying technologies.

14. Why must aggressive scanning/fingerprinting remain inside the authorised lab?

- Aggressive scanning and fingerprinting can generate a significant amount of network traffic and may trigger security alerts or intrusion detection systems. Performing such scans on unauthorized networks can be considered illegal or malicious activity, leading to potential legal consequences. Therefore, it is essential to conduct these activities only within authorized lab environments where permission has been granted.
