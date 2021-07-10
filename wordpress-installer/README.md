This script helps to install the wordpress, provided you have web server and mysql already running in the server.

Usage:

wget https://raw.githubusercontent.com/thilaks-hub/bash-repo/master/wordpress-installer/wp-installer.sh

bash wp-installer.sh

It will prompt for the domain name and path to install wordpress.

Domain name example: example.com www.example.com

Path example : /var/www/html

Once installed you will get the username and password as shown.

=================================================================================
Username : wpadmin
Password : Kx5SsDePvNH0RvD8
Domain name : example.com
=================================================================================

You may login to wordpress using example.com/wp-admin, provided you have added domain in the server, document root is same as path and domain is resolving to the host.