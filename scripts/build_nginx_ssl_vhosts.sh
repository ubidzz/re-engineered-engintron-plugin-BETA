#!/bin/bash

## Setting the variables for the Folder paths ##
CHAINPATH='/etc/nginx/ssl/caboundles';
CUSTOMCERTSPATH='/etc/nginx/ssl/certs';
CUSTOMKEYPATH='/etc/nginx/ssl/keys';
VHOSTPATH='/etc/nginx/ssl/vhosts';

echo "|--Searching the cPanel httpd.conf file for all domains that have SSL installed.....";
echo "|---------------------------------------------------------------";

function rebuildSSLvhosts
{
	while read ServerName SSLCertificateFile SSLCertificateKeyFile SSLCACertificateFile
	do
		## Making sure the SSL cert and key was found before creating the conf file ##
		if [[ -n $SSLCertificateFile ]] && [[ -n $SSLCertificateKeyFile ]]
		then
			## Removing the . and - from the domain and replacing it with _ ##
			fqdn=${ServerName//./_};
			fqdnServerName=${fqdn//-/_};

			## Checking to see if the SSL was deleted from httpd.conf file
			checkVhosts $fqdnServerName.conf

			echo "|--|--Installing $ServerName nginx SSL conf file.........";
			echo "|--|--|--The SSL cert file was found and was copied to the $CUSTOMCERTSPATH folder.";
			sed -n 'p' $SSLCertificateFile $SSLCACertificateFile > $CUSTOMCERTSPATH/$fqdnServerName.crt;
			echo "|--|--|--|--SSL cert file: $CUSTOMCERTSPATH/$fqdnServerName.crt";

			echo "|--|--|--The SSL key file was found and was copied to the $CUSTOMKEYPATH folder.";
			cp $SSLCertificateKeyFile $CUSTOMKEYPATH/$fqdnServerName.key;
			echo "|--|--|--|--SSL key file: $CUSTOMKEYPATH/$fqdnServerName.key";

			## checking to see if the CAboundle was found ##
			if [[ -n $SSLCACertificateFile ]]
			then
				echo "|--|--|--The SSL CAboundle file was found and was copied to the $CHAINPATH folder.";
				cp $SSLCACertificateFile $CHAINPATH/$fqdnServerName.pem;
				echo "|--|--|--|--SSL CAboundle file: $CHAINPATH/$fqdnServerName.pem";

				CABOUNDLEDATA=$"# ============ Start OCSP stapling protection ============
					ssl_stapling on;
					ssl_stapling_verify on;
					ssl_trusted_certificate $CHAINPATH/$ServerName.pem;
					# ============ End OCSP stapling protection ============
				";
				## Displaying a error that the CAboundle was not found ##
				echo "|--|--|--ERROR!";
				echo "|--|--|--|--The SSL CAboundle file could not be found for this domain $ServerName";
				echo "|--|--|--|--Could not add the OCSP stapling protection to the $fqdnServerName.conf file because the SSL CAboundle file is missing.";
			fi

	## SSL domain_com.conf template ##
	FILEDATA=$"# /**
	#  * @version    1.7.2
	#  * @package    Engintron for cPanel/WHM
	#  * @author     Fotis Evangelou
	#  * @url        https://engintron.com
	#  * @copyright  Copyright (c) 2010 - 2016 Nuevvo Webware P.C. All rights reserved.
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
	echo "|--|--The SSL $fqdnServerName.conf file was successfully created";
	echo "|--|--|-- SSL conf file: $VHOSTSPATH/$fqdnServerName.conf";
	echo "|---------------------------------------------------------------";
	fi
	done< <(awk '/^<VirtualHost*/,/^<\/VirtualHost>/{if(/^<\/VirtualHost>/)p=1;if(/ServerName|SSLCertificateFile|SSLCertificateKeyFile|SSLCACertificateFile|## ServerName/)out = out (out?OFS:"") (/User/?$3:$2)}p{print out;p=0;out=""}' /usr/local/apache/conf/httpd.conf) 
}

function deleteAllVhosts
{
        ## Checking to see if the SSL was deleted from httpd.conf file
        for domain in  `ls $VHOSTSPATH/*.conf`
        do
		echo "├──├──SSL was deletd from the httpd.conf";
		echo "├──├──├──Deleteing SSL stuff for $fqdnServerName";
		rm -rf $VHOSTSPATH/$TLD.conf;
		rm -rf $CUSTOMKEYPATH/$TLD.key;
		rm -rf $CUSTOMCERTSPATH/$TLD.crt;
		rm -rf $CHAINPATH/$TLD.pem;
        done
	rebuildSSLvhosts
}

deleteAllVhosts;

echo "|--Reloading nginx";
service nginx reload;
