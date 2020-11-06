# Overview
Configure Always On VPN from an Azure VPN Gateway.  

### Example
You need to modify the xml with your config. Modifications examples:
<DnsSuffix>domain.com</DnsSuffix>
<Servers>vpn.domain.com</Servers>
<TrustedNetworkDetection>domain.com</TrustedNetworkDetection>
 <DomainName>domain.com</DomainName>
 <DnsServers>8.8.8.8</DnsServers>

### Deploy the Profile to Windows 10
.\Deploy-VPN.ps1 .\VPN-Profile.xml 'Azure VPN'
