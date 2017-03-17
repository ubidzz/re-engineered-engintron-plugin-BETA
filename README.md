# Right the install script is not finished and will install the default nginx and enginered plugin and is not ready to be used yet.

# Re-enginered-engintron-plugin-BETA
Enable HTTP/2, OCSP stapling, ALPN, NPN, HSTS, Strict-Transport-Security and compiled with a newer version of OpenSSL

<b>Importing INFO!</b><br>
This is a re-enginered engintron cPanel/WHM plugin and the credit goes to Fotis Evangelou for the plugin and the credit for the re-enginered plugin goes to Jason Turner.

Engintron URL: https://engintron.com

The difference between Engintron and Nginx Engine plugins

<b>Engintron</b>
<ol>
<li>Have to disable php open_basedir Protection
<li>Websites load using http 1.1 protocol and not http/2
<li>It use OpenSSL 1.0.1e-fips
<li>All https vhosts are compiled in 1 file
</ol>

<b>Nginx Engine</b>
<ol>
<li>Don't have to disable the php open_basedir Protection
<li>Sets the Strict-Transport-Security, X-Frame-Options, Referrer-Policy headers
<li>Compiled with a newer version of OpenSSL 1.0.2k or higher
<li>Can handle ALPN, NPN http/2 protocols
<li>https vhosts are compiles in separate conf files
<li>The SSL crt, key and caboundle files are copied and are saved in separate directories.
</ol>

<b>Information</b><br>
This plugin will search the /usr/local/apache/conf/httpd.conf file for all the virtual hosts that have SSL installed by cPanel AutoSSL or by the user in cPanel. This plugin will run every 1 minute to create/update/delete the domain_com.conf, domain_com.crt, domain_com.key and domain_com.pem files. When it is searching the /usr/local/apache/conf/httpd.conf file it will get the installed key, cert, caboundle paths and copy them in to the nginx ssl folders. So if you ever unstall this plugin it wont delete the apache cert, key and cabound files because the nginx server has it own copys. 

<b>SSL-plugin-for-engintron install tree</b><br>
├──/etc/cron.d/ (Cronjob Folder)<br>
├──├──nginx_ssl (Cronjob to run the build_nginx_ssl_vhosts.sh file every 1 minute)<br>
├──/etc/nginx/ (Nginx Folder)<br>
├──├──proxy_params_common (File)<br>
├──├──conf.d (nginx conf Folder)<br>
├──├──├──default_ssl.conf<br>
├──├──ssl_proxy_params_common (File)<br>
├──├──ssl (SSL Folder)<br>
├──├──├──build_nginx_ssl_vhosts.sh (Used to build/update/delete the caboundle, cert, key and the domain SSL conf files)<br>
├──├──├──caboundles (All domains caboundle files will be copied here)<br>
├──├──├──certs (All domains cert files will be copied here)<br>
├──├──├──keys (All domains key files will be copied here)<br>
├──├──├──vhosts (All domains SSL conf files will be created here)<br>

You can SSH and run this /etc/nginx/ssl/build_nginx_ssl_vhosts.sh command to run the plugin to create/update/delete the domains crt, key, caboundle and conf files or the cronjob will do it for you automatically every 1 minute.

It will delete all the SSL stuff first then rebuild all the installed SSL that is found in the httpd.conf file. This is to make sure that if any unstalled SSL or deleted SSL from the httpd.comf file is deleted from the nginx server.

<b>Here is a output example from SSH</b><br>
├──Deleting all SSL stuff.....<br>
├──────────────────────────────────────────────────────────────<br>
├──Deleting latatinachecrea_creomarket_it SSL stuff<br>
├──────────────────────────────────────────────────────────────<br>
├──Deleting my_hosted_website_com SSL stuff<br>
├──────────────────────────────────────────────────────────────<br>
├──Now starting the rebuild SSL command<br>
|──Searching the cPanel httpd.conf file for all domains that have SSL installed.....<br>
├──────────────────────────────────────────────────────────────<br>
├──├──Installing my-hosted-website.com SSL conf file.........<br>
├──├──├──The SSL cert file was found and was copied to the /etc/nginx/ssl/certs folder.<br>
├──├──├──├──SSL cert file: /etc/nginx/ssl/certs/my_hosted_website_com.crt<br>
├──├──├──The SSL key file was found and was copied to the /etc/nginx/ssl/keys folder.<br>
├──├──├──├──SSL key file: /etc/nginx/ssl/keys/my_hosted_website_com.key<br>
├──├──├──The SSL CAboundle file was found and was copied to the /etc/nginx/ssl/caboundles folder.<br>
├──├──├──├──SSL CAboundle file: /etc/nginx/ssl/caboundles/my_hosted_website_com.pem<br>
├──├──The SSL my_hosted_website_com.conf file was successfully created<br>
├──├──├──SSL conf: /etc/nginx/ssl/vhosts/my_hosted_website_com.conf file<br>
├──────────────────────────────────────────────────────────────<br>
├──├──Installing latatinachecrea.creomarket.it SSL conf file.........<br>
├──├──├──The SSL cert file was found and was copied to the /etc/nginx/ssl/certs folder.<br>
├──├──├──├──SSL cert file: /etc/nginx/ssl/certs/latatinachecrea_creomarket_it.crt<br>
├──├──├──The SSL key file was found and was copied to the /etc/nginx/ssl/keys folder.<br>
├──├──├──├──SSL key file: /etc/nginx/ssl/keys/latatinachecrea_creomarket_it.key<br>
├──├──├──ERROR!<br>
├──├──├──├──The SSL CAboundle file could not be found for this domain latatinachecrea.creomarket.it<br>
├──├──├──├──Could not add the OCSP stapling protection to the latatinachecrea_creomarket_it.conf file because the SSL CAboundle file is missing.<br>
├──├──The SSL latatinachecrea_creomarket_it.conf file was successfully created<br>
├──├──├──SSL conf: /etc/nginx/ssl/vhosts/latatinachecrea_creomarket_it.conf file<br>
├──────────────────────────────────────────────────────────────<br>
├──Reloading nginx<br>
Redirecting to /bin/systemctl reload  nginx.service<br>

