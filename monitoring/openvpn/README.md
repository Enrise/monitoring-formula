# OpenVPN monitoring

## Templates

### Template_App_OpenVPN_Clients
Client auto-detection based on client config files residing in `/etc/openvpn/users.conf.d`.

### Template_App_OpenVPN
Monitoring of OpenVPN itself. It makes the following assumptions:
* You are using the port-share on 443
* Your webserver listens on 10443
