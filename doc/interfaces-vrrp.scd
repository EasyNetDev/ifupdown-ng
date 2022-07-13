interfaces-vrrp(5)

# NAME

*interfaces-vrrp* - VRRP extensions for the interfaces(5) file format

# DESCRIPTION

FFRouring is able to use MACVLAN interfaces for VRRP. Linux has support
for macvlan interfaces with protodown since Kernel >= 5.1.
The ifupdown-ng executor will create 2 different MACVLAN interfaces using
CRC32 checksum to create the names for the interfaces. 
This assures the names remains persistents each time we are creating the 
VRRPs and also we are sure the name is not be more than 15 characters, 
which is the limit of Linux interface name.

One interface is for IPv4 and the other one is for IPv6. See RFC 3768 and 
RFC 5798.

The following options allow to set up VRRPs.

# VRRP-RELATED OPTIONS

*vrrp-id* _id_ [_id_]
        In case is needed to create only the MACVLAN interfaces, use this
        option. Also is an alias for *vrrp-address* _id_ [_id_]

*vrrp-address* _id_ [_address_ [_address_]] [_id_ [_address_ [_address_]]]
        The _id_ is the Virtual Router ID. Can have values between 1 and 255.
        The _address_ can be optional. This is the VRRP IPv4 or IPv6 address
        which is the backup IP.
        If address is omited then ifupdown-ng will just create the macvlan
        interfaces. You have to add the IPs from FRRouting or manually.
        Address should be CIDR format IP/PREFIX.
        Note: don't use /32 for backup interfaces. There are chances to
        have issues with the traffic. Use the same prefix as per subnet!
        By default if you are not giving a prefix to the IP, the script
        will add /24 or /64 by default.

Note: *vrrp-address* has priority over *vrrp-id*, because if both of options
are given, then only *vrrp-address* it will be processed.

You can use multiple VRRP IDs for one single interface, but they definitely 
must differ. Don't use multiple time same VRRP ID on same interface, only 2 
interfaces are created per VRRP ID.

# EXAMPLES

A VRRP example:

```
auto eth0
iface eth0
        address 192.168.0.2/24
        vrrp-address 10 192.168.0.1/24

auto eth1
iface eth1
        address 172.17.0.2/24
        address 172.17.1.2/24
        address 172.17.2.2/24
        address fc00:172:17:0::2/64
        address fc00:172:17:1::2/64
        address fc00:172:17:2::2/64
        vrrp-address 16 172.17.0.1/24 172.17.1.1/24 fc00:172:17:0::1/64 fc00:172:17:1::1/64 17 172.17.2.1/24 fc00:172:17:2::1/64

# Create only the MACVLAN interfaces
auto eth3
iface eth3
        vrrp-id 18 19
# Or instead vrrp-id you can use vrrp-address
        vrrp-address 18 19
```

We will have 2 additional interfaces for eth0: vrrp4-db559fac and vrrp6-d8e4c6a2,
and 2 additional interfaces for eth1: vrrp4-321a0fff and vrrp6-31ab56f1.

Also the MAC addresses will be in form 00:00:5e:00:0X:YY where YY is VRRP ID
in hexa and X is protocol version: 01 for IPv4 and 02 for IPv6.
So the MAC addresses are: 00:00:5e:00:01:0a for vrrp4-db559fac and
00:00:5e:00:02:0a for vrrp4-d8e4c6a2.

The vrrp-address option has a VRRP ID 16 with 2 IPv4 addresses and 2 IPv6 address.
Then we have VRRP ID 17 with one IPv4 address and one IPv6 address.

VRRP interface IP (whitout prefix) MUST match the VRRP configuration IP in FRR.

The FRR config will look like this:

```
interface eth0
 description VRRP #1 example
 vrrp 10
 vrrp 10 priority 120
 vrrp 10 ip 192.168.0.1

interface eth1
 description VRRP #2 example
 vrrp 16 ip 172.17.0.1
 vrrp 16 ip 172.17.1.1
 vrrp 16 ipv6 fc00:172:17:0::1
 vrrp 16 ipv6 fc00:172:17:1::1
```


If we are checking the VRRP on FRR we will see:

```
# show vrrp interface eth0

 Virtual Router ID                       10                        
 Protocol Version                        3                         
 Autoconfigured                          No                        
 Shutdown                                No                        
 Interface                               eth0                      
 VRRP interface (v4)                     vrrp4-db559fac            
 VRRP interface (v6)                     vrrp6-d8e4c6a2            
 Primary IP (v4)                         192.168.0.2               
 Primary IP (v6)                         fe80::200:5eff:fe00:210   
 Virtual MAC (v4)                        00:00:5e:00:01:0a         
 Virtual MAC (v6)                        00:00:5e:00:02:0a         
 Status (v4)                             Master                    
 Status (v6)                             Master                    
 Priority                                100                       
 Effective Priority (v4)                 100                       
 Effective Priority (v6)                 100                       
 Preempt Mode                            Yes                       
 Accept Mode                             Yes                       
 Advertisement Interval                  1000 ms                   
 Master Advertisement Interval (v4) Rx   1000 ms (stale)           
 Master Advertisement Interval (v6) Rx   1000 ms (stale)           
 Advertisements Tx (v4)                  2660729                   
 Advertisements Tx (v6)                  2660728                   
 Advertisements Rx (v4)                  0                         
 Advertisements Rx (v6)                  0                         
 Gratuitous ARP Tx (v4)                  1                         
 Neigh. Adverts Tx (v6)                  1                         
 State transitions (v4)                  2                         
 State transitions (v6)                  2                         
 Skew Time (v4)                          600 ms                    
 Skew Time (v6)                          600 ms                    
 Master Down Interval (v4)               3600 ms                   
 Master Down Interval (v6)               3600 ms                   
 IPv4 Addresses                          1                         
 ..................................      192.168.0.1               
 IPv6 Addresses                          1                         
 ..................................      fc00:192:168:0::1         

# show vrrp interface eth1

 Virtual Router ID                       16                        
 Protocol Version                        3                         
 Autoconfigured                          No                        
 Shutdown                                No                        
 Interface                               eth1                      
 VRRP interface (v4)                     vrrp4-321a0fff            
 VRRP interface (v6)                     vrrp6-31ab56f1            
 Primary IP (v4)                         172.17.0.2                
 Primary IP (v6)                         fe80::200:5eff:fe00:211   
 Virtual MAC (v4)                        00:00:5e:00:01:10         
 Virtual MAC (v6)                        00:00:5e:00:02:10         
 Status (v4)                             Master                    
 Status (v6)                             Master                    
 Priority                                100                       
 Effective Priority (v4)                 100                       
 Effective Priority (v6)                 100                       
 Preempt Mode                            Yes                       
 Accept Mode                             Yes                       
 Advertisement Interval                  1000 ms                   
 Master Advertisement Interval (v4) Rx   1000 ms (stale)           
 Master Advertisement Interval (v6) Rx   1000 ms (stale)           
 Advertisements Tx (v4)                  2660729                   
 Advertisements Tx (v6)                  2660728                   
 Advertisements Rx (v4)                  0                         
 Advertisements Rx (v6)                  0                         
 Gratuitous ARP Tx (v4)                  1                         
 Neigh. Adverts Tx (v6)                  1                         
 State transitions (v4)                  2                         
 State transitions (v6)                  2                         
 Skew Time (v4)                          600 ms                    
 Skew Time (v6)                          600 ms                    
 Master Down Interval (v4)               3600 ms                   
 Master Down Interval (v6)               3600 ms                   
 IPv4 Addresses                          2                         
 ..................................      172.17.0.1                
 ..................................      172.17.1.1                
 IPv6 Addresses                          2                         
 ..................................      fc00:172:17:0::1          
 ..................................      fc00:172:17:1::1          

```

# SEE ALSO

*ip-link*(8)
*http://docs.frrouting.org/en/latest/vrrp.html*


# AUTHORS

EasyNetDev <devel@easynet.dev>
