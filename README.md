# SSL-plugin-for-engintron-BETA
Enable HTTP/2, OCSP stapling and automatically build the SSL conf files for nginx

<b>Requirements:</b> Installed engintron plugin for WHM/cPanel

<b>I have not yet made the install page for this plugin and this plgin is still being developed.</b>

<b>Information</b>
This plugin will search the /usr/local/apache/conf/httpd.conf file for all the virtual hosts that have SSL installed by cPanel AutoSSL or by the user in cPanel. This plugin will run every hour to create/update/delete the domain_com.conf, domain_com.crt, domain_com.key and domain_com.pem files. When it is searching the /usr/local/apache/conf/httpd.conf file it will get the installed key, cert, caboundle paths and copy them in to the nginx ssl folders. So if you ever unstall this plugin it wont delete the apache cert, key and cabound files because the nginx server has it own copys. 

<b>SSL-plugin-for-engintron files and folders tree</b><br>
├──/etc/cron.d/ (Folder)<br>
├──├──nginx_ssl (file)<br>
├──/etc/nginx/ (Folder)<br>
├──├──ssl_proxy_params_common (File)<br>
├──├──ssl (Folder)<br>
├──├──├──build_nginx_ssl_vhosts.sh (file)<br>
├──├──├──caboundles (Folder)<br>
├──├──├──certs (Folder)<br>
├──├──├──keys (Folder)<br>
├──├──├──vhosts (Folder)<br>
