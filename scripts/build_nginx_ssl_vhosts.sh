#!/bin/bash

## Setting the variables for the Folder paths ##
CHAINPATH='/etc/nginx/ssl/caboundles';
CUSTOMCERTSPATH='/etc/nginx/ssl/certs';
CUSTOMKEYPATH='/etc/nginx/ssl/keys';
VHOSTPATH='/etc/nginx/ssl/vhosts';

echo "|──Starting the SSL prosseces";
echo "|──────────────────────────────────────────────────────────────────────";

function buildConfFile
{
## SSL domain_com.conf template ##
FILEDATA=$"# /**
#  * @version    1.8.0
#  * @package    Engintron for cPanel/WHM
#  * @author     Fotis Evangelou
#  * @url        https://engintron.com
#  * @copyright  Copyright (c) 2010 - 2017 Nuevvo Webware P.C. All rights reserved.
#  * @license    GNU/GPL license: http://www.gnu.org/copyleft/gpl.html
#  */
server {
	listen 443 ssl http2;
	server_name $ServerName www.$ServerName;
		
	ssl_certificate      $CUSTOMCERTSPATH/$fqdnServerName.crt;
	ssl_certificate_key  $CUSTOMKEYPATH/$fqdnServerName.key;
		
	$CABOUNDLEDATA
		
	include ssl_proxy_params_common;
}";
	
	## Empty the CABOUNDLEDATA variables each time it loops so that we don't ##
	## add the wrong CAboundle info in to the vhost that is being created ##
	CABOUNDLEDATA="";

	echo "$FILEDATA" > $VHOSTPATH/$fqdnServerName.conf;
	echo "├──├──The SSL $fqdnServerName.conf file was successfully created";
	echo "├──├──├── SSL conf file: $VHOSTSPATH/$fqdnServerName.conf";
	echo "|──────────────────────────────────────────────────────────────────────";
}

function rebuildSSLvhosts
{
	echo "|──Searching the cPanel httpd.conf file for all domains that have SSL installed.....";
	echo "|──────────────────────────────────────────────────────────────────────";
	
	while read ServerName ServerAlias SSLEngine SSLCertificateFile SSLCertificateKeyFile SSLCACertificateFile
	do
		## Making sure the SSL cert and key was found before creating the conf file ##
		if [[ -e $SSLCertificateFile ]] && [[ -e $SSLCertificateKeyFile ]] && [[ $SSLEngine="on" ]];
		then
			## Removing the . and - from the domain and replacing it with _ ##
			fqdn=${ServerName//./_};
			fqdnServerName=${fqdn//-/_};

			echo "|──|──Installing $ServerName nginx SSL conf file.........";
			echo "|──|──|──The SSL cert file was found and was copied to the $CUSTOMCERTSPATH folder.";
			sed -n 'p' $SSLCertificateFile $SSLCACertificateFile > $CUSTOMCERTSPATH/$fqdnServerName.crt;
			echo "|──|──|──|──SSL cert file: $CUSTOMCERTSPATH/$fqdnServerName.crt";

			echo "|──|──|──The SSL key file was found and was copied to the $CUSTOMKEYPATH folder.";
			cp $SSLCertificateKeyFile $CUSTOMKEYPATH/$fqdnServerName.key;
			echo "|──|──|──|──SSL key file: $CUSTOMKEYPATH/$fqdnServerName.key";

			## checking to see if the CAboundle was found ##
			if [[ -n $SSLCACertificateFile ]]
			then
				echo "|──|──|──The SSL CAboundle file was found and was copied to the $CHAINPATH folder.";
				sed -n 'p' $SSLCertificateFile $SSLCACertificateFile > $CHAINPATH/$fqdnServerName.pem;
				echo "|──|──|──|──SSL CAboundle file: $CHAINPATH/$fqdnServerName.pem";

				CABOUNDLEDATA=$"# ============ Start OCSP stapling protection ============
				ssl_stapling on;
				ssl_stapling_verify on;
				ssl_trusted_certificate $CHAINPATH/$fqdnServerName.pem;
				# ============ End OCSP stapling protection ============
				";
			else
				## Displaying a error that the CAboundle was not found ##
				echo "|──|──|──ERROR!";
				echo "|──|──|──|──The SSL CAboundle file could not be found for this domain $ServerName";
				echo "|──|──|──|──Could not add the OCSP stapling protection to the $fqdnServerName.conf file because the SSL CAboundle file is missing.";
			fi
			buildConfFile;
	fi
	done< <(awk '/^<VirtualHost*/,/^<\/VirtualHost>/{if(/^<\/VirtualHost>/)p=1;if(/ServerName|ServerAlias|SSLEngine|SSLCertificateFile|SSLCertificateKeyFile|SSLCACertificateFile|## ServerName/)out = out (out?OFS:"") (/User/?$3:$2)}p{print out;p=0;out=""}' /usr/local/apache/conf/httpd.conf) 
	
	echo "├──Reloading nginx";
	service nginx reload;
}

function deleteAllVhosts
{
	echo "|──Deleting all the domains SSL stuff.....";
	echo "|──────────────────────────────────────────────────────────────────────";
        ## Checking to see if the SSL was deleted from httpd.conf file
        for domain in  `ls $VHOSTPATH/*.conf`
        do
                name=${domain#$VHOSTPATH/};
                cleanname=${name//.conf/};
                echo "├──Deleting $cleanname SSL stuff";
		echo "|──────────────────────────────────────────────────────────────────────";
                rm -rf $VHOSTSPATH/$cleanname.conf;
                rm -rf $CUSTOMKEYPATH/$cleanname.key;
                rm -rf $CUSTOMCERTSPATH/$cleanname.crt;
                rm -rf $CHAINPATH/$cleanname.pem;
        done
	echo "├──Now starting the rebuild SSL processe";
	rebuildSSLvhosts;
}

deleteAllVhosts;
