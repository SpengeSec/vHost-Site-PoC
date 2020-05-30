#!/usr/bin/env bash
echo "** Script created by SpengeSec aka R0716728**"

if [[ $# -eq 0 ]] ; then
    echo 'Usage: sudo bash <scriptname.sh> <name> <password> <website.com>'

    exit 0
fi


NAME=${1?Error: no name given}
PASSWD=${2?Error: no password given}
SITE=${3?Error: no site nam given}



#Create user with his own home dir
echo "* Adding new user $NAME"
useradd -s /bin/bash -m -d /home/$NAME $NAME

#Assign password to this user
echo "$NAME:$PASSWD" | chpasswd
echo "* Password set for user $NAME"

#Create virtual host dir for this user
mkdir -p -m o-rwx /var/vhosts/$NAME
echo "* Created Virtual host directory"

#Change ownership of vhost dir
chown -R $NAME:$NAME /var/vhosts/$NAME
echo "* Changing ownership for vhost directory"

#Add apache user www-data to user group 
usermod -a -G $NAME www-data
#(The statement above gives apache web server the required permissions in order to run all of the user's websites.)
echo "* Added user $NAME to www-data usergroup"

#echo "Alias /$NAME /var/vhosts/$NAME
#        <Directory /var/vhosts/$NAME
#                Options None
#                AllowOverride All
#                Order allow,deny
#                Allow from all
#        </Directory>" >> /etc/apache2/apache2.conf

#Create Apache available-sites vhost configuration file
cp /etc/apache2/sites-available/brent.com.conf /etc/apache2/sites-available/$SITE.conf
echo "" > /etc/apache2/sites-available/$SITE.conf
echo "* Duplicating default apache2 vhost configuration"

echo "<VirtualHost *:80>

        ServerAdmin webmaster@localhost
        DocumentRoot /var/vhosts/$NAME
        ServerName www.$SITE
        ServerAlias $SITE

        <Directory />
                Options FollowSymLinks
                AllowOverride None
        </Directory>
        <Directory /var/vhosts/$NAME/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>

        CustomLog ${APACHE_LOG_DIR}/$SITE.access.log combined
        ErrorLog ${APACHE_LOG_DIR}/$SITE.error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

</VirtualHost>" > /etc/apache2/sites-available/$SITE.conf
echo "* Done writing vhost configuration"
#Enable the new vhost in apache2
cd /etc/apache2/sites-available/
a2ensite $SITE.conf &> /dev/null #(Hide command output)
echo "* Enabled new vhost in apache2"
#Restart the apache2 service
systemctl reload apache2
echo "* Reloaded apache2 service"

#Write default index.html for this user
touch /var/vhosts/$NAME/index.html
echo "Website successfully created!" > /var/vhosts/$NAME/index.html
echo "* Default index.html created"

#Create symbolic link to user home dir for FTP access
ln -s /var/vhosts/$NAME /home/$NAME
echo "* Symbolic link from /var/vhosts/$NAME to /home/$NAME created!"
echo "* All done, website available!"
