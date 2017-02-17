# SSL-plugin-for-engintron-BETA
Enable HTTP/2, OCSP stapling and automatically builds the SSL conf files for all domains that has SSL installed

<b>Requirements:</b><br>
Installed engintron plugin for WHM/cPanel<br>
Apache SSL port must be set to 444

<b>I have not yet made the install page for this plugin and this plugin is still being developed.</b>

<b>Information</b><br>
This plugin will search the /usr/local/apache/conf/httpd.conf file for all the virtual hosts that have SSL installed by cPanel AutoSSL or by the user in cPanel. This plugin will run every hour to create/update/delete the domain_com.conf, domain_com.crt, domain_com.key and domain_com.pem files. When it is searching the /usr/local/apache/conf/httpd.conf file it will get the installed key, cert, caboundle paths and copy them in to the nginx ssl folders. So if you ever unstall this plugin it wont delete the apache cert, key and cabound files because the nginx server has it own copys. 

<b>SSL-plugin-for-engintron tree</b><br>
├──/etc/cron.d/ (Cronjob Folder)<br>
├──├──nginx_ssl (Cronjob to run the build_nginx_ssl_vhosts.sh every hour)<br>
├──/etc/nginx/ (Nginx Folder)<br>
├──├──ssl_proxy_params_common (File)<br>
├──├──ssl (SSL Folder)<br>
├──├──├──build_nginx_ssl_vhosts.sh (Used to build/update/delete the caboundle, cert, key and the domain SSL conf files)<br>
├──├──├──caboundles (All domains caboundle files will be copied here)<br>
├──├──├──certs (All domains cert files will be copied here)<br>
├──├──├──keys (All domains key files will be copied here)<br>
├──├──├──vhosts (All domains vhost files will be created here)<br>

You can SSH and run this /etc/nginx/ssl/build_nginx_ssl_vhosts.sh command to run the plugin to create/update/delete the domains crt, key, caboundle and conf files or the cronjob will do it for you automatically every hour.
