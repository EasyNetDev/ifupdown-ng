interfaces-team(5)

# NAME

*interfaces-team* - Network Teaming/LAG extensions for the interfaces(5) file format

# DESCRIPTION

The _Network Teaming_ or _Team_ is the new implementation for Link Aggregation Groups (LAGs).
_Network Teaming_ is designed to implement the concept in a different way by 
providing a small kernel driver to implement the fast handling of packet flows,
and various user-space applications to do everything else in user space.
_Network Teaming_ has support for different types of LAGs: _Broadcast_, _Round Robin_,
_Active-Backup_, _Load Balance_ and _LACP_ (802.3ad).

The following options set up Network Teaming/LAG interfaces with ifupdown-ng.

See https://www.kernel.org/doc/Documentation/networking/team.rst and
https://github.com/jpirko/libteam for more information.

# TEAMING VS BONDING COMPARATION

In this manual you will find only general descripions or just the name of the options.
More detailes about each option you can find in the manual for *teamd.conf(5)* 
or on these sites:
https://www.unix.com/man-page/centos/5/teamd.conf/
https://www.systutorials.com/docs/linux/man/5-teamd/.

Differences between teaming and bonding:
. *Bonding* has the _mode_ to select the type of the LAG, 
  *Teaming* has the _runner_ which is selecting the type of the LAG.
. *Teaming* can have separate configuration for each port.
. *Teaming* is running the controller in user-space, *Bonding* on the
  other hand is running completely in kernel. So *Teaming* driver has a 
  smaller footprint and is faster for packet throughput.
. *Teaming* has support for IPv6 (NA/NS) link monitoring.
. *Teaming* has less performance overhead.
. *Teaming* has modular design allows function extensible option in future.

# TEAM-RELATED OPTIONS

*team-runner* _runner_
	Denotes the name of the runner for this LAG. The _runner_ is a
	string value and it can have these valid values: _broadcast_,
	_roundrobin_, _activebackup_, _loadbalance_ and _lacp_.

*team-link-watch* _link watch_
	Denotes the  for monitoring the links for each member.
	Valid values are: _ethtool_, _arp_ping_ and _nsna_ping_.

*team-link-watch-options* _list of options_
	For each _Link Watch_ there are several additional parameters.
	Valid list of values are:
		. *ethtool*: _delay_up_, _delay_down_.
		. *arp_ping*: _interval_, _init_wait_, _missed_max_,
		  _source_host_, _target_host_, _validate_active_,
		  _validate_inactive_ and _send_always_.
		. *nsna_ping*: _interval_, _init_wait_, _missed_max_ 
		  and _target_host_.

*team-members* _list of interfaces_(_list of options_)
	Denotes the physical member interfaces to form this LAG.
	This option is should be configure, otherwise the _team_.
	interface will be configured but without _members_.++
Each member can have an optional list of comma separated options and 
	framed in parentheses, right away after the name of every port member.++
++
*Do not use spaces between the port member name and parentheses or between the <list of options>!*++
++
Valid values for the _list of options_ are:
		. Runner _Active-Backup_ runner: *prio* and *sticky*
		. Runner _LACP_ runner: *lacp_prio* and *lacp_key*
		. Link watch _ethtool_: same as link watch options.
		. Link watch _arp_ping_: same as link watch options.
		. Link watch _nsna_ping_: same as link watch options.
++
	See the examples below.

*team-activebackup* _list of options_
	Comma separated options for *Active-Backup* runner.++
Valid values are: _hwaddr_policy_.

*team-loadbalance* _list of options_
	Comma separated options for *Load-Balance* runner.++
Valid values are: _tx_hash_, _tx_balancer.name_, _tx_balancer.balancing_interval_.

*team-lacp* _list of options_
	Comma separated options for *LACP* runner.++
Valid values are: _active_, _fast_rate_, _tx_hash_, _tx_balancer.name_, _tx_balancer.balancing_interval_, _sys_prio_, _min_ports_, _agg_select_policy_.

*team-notify-peers* _list of options_
	Comma separated options for *unsolicited NAs and gratuitous ARP packets*.++
Valid values are: _count_ and _interval_.

*team-mcast-rejoin* _list of options_
	Comma separated options for *multicast group rejoin requests*.++
Valid values are: _count_ and _interval_.

# SPECIAL OPTIONS

*tx_hash* _list of tx hashesh_
	List of hash algorithms, separated by *+* sign, to be used for transmited packtes.
	Valid options: *eth*, *vlan*, *ipv4*, *ipv6*, *ip*, *l3*, *tcp*, *udp*, *sctp* and *l4*.++
Example: team-lacp tx_hash=eth+vlan+ip+l3+l4

# EXAMPLES

A team interface using three links, *LACP (802.3ad)* and *eth*, *vlan*, *ip*, *L3* and *L4*
hash algorithm for TX, *ethtool* as link monitor with a 200ms *delay-up* and 100ms *delay-down*
and special *delays* for eth3:

```
auto team0
iface team0
	team-members eth0 eth1 eth3(delay_up=100,delay_down=0,lacp_prio=100)
	team-runner lacp
	team-lacp fast_rate=true,tx_hash=eth+vlan+ip+l3+l4,tx_balancer.name=basic
	team-link-watch ethtool
	team-link-watch-options delay_up=200,delay_down=0
	#
	address 192.0.2.42/24
	address 2001:db8::42/64
```

A team interface with ACTIVE-BACKUP runner:

```
auto team0
iface team0
	team-members eth1 eth2(prio=100,sticky=true)
	team-runner activebackup
```

A team interface with LOAD BALANCE runner:
```
auto team0
iface team0
	team-members eth1 eth2(prio=100,sticky=true)
	team-runner loadbalance
	team-loadbalance tx_hash=eth+vlan+ip,tx_balancer.name=basic
```

# AUTHORS

Adrian Ban <devel@easynet.dev>
