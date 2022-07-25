NC='\033[0m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
clear
echo -e "${BLUE}"
echo "        ___        _   _  __      _    ____  _ _   _           _                       _     "
echo "       / / |      | | | |/_ |    | |  |___ \| | | | |         (_)                     | |    "
echo "      / /| | _____| |_| |_| | ___| |__  __) | | |/ __)_      ___ _ __   __ _ ___   ___| |__  "
echo "     / / | |/ / _ \ __| __| |/ _ \ '_ \|__ <| | |\__ \ \ /\ / / | '_ \ / _\` / __| / __| '_ \ "
echo "  _ / /  |   <  __/ |_| |_| |  __/ |_) |__) | | |(   /\ V  V /| | | | | (_| \__ \_\__ \ | | |"
echo " (_)_/   |_|\_\___|\__|\__|_|\___|_.__/____/|_|_| |_|  \_/\_/ |_|_| |_|\__, |___(_)___/_| |_|"
echo "                                              ______                    __/ |                "
echo "                                             |______|                  |___/                 "
echo ""


                                                                                


echo -e "Setup script for the linux machine ${NC}"

if [[ $1 = "--purge" ]]
then
	echo -e "${GREEN}[+]${NC}	Removing MySQL"
	sudo apt-get remove --purge *mysql\* -y > /dev/null
	sudo apt-get autoremove -y > /dev/null
	echo -e "${GREEN}[+]${NC}	Removing Apache2"
	sudo apt-get purge apache2 apache2-utils apache2-bin apache2.2-common -y > /dev/null
	sudo apt-get autoremove -y > /dev/null
elif [[ $1 = "--help" ]]
then
	echo "T"
else
	echo -e "${GREEN}[+]${NC}	Installing Apache2"
	sudo apt-get install apache2 -y > /dev/null

	sudo rm -R /var/www/html/* || :

	cd /var/www/html/ > /dev/null

	echo -e "${GREEN}[+]${NC}	Cloning website"
	sudo git clone https://github.com/c0ups/VulnerableSite.git 2> /dev/null

	sudo chmod -R 777 /var/www/html/VulnerableSite/ > /dev/null

	sudo mv /var/www/html/VulnerableSite/* /var/www/html/ > /dev/null

	sudo rm -R VulnerableSite > /dev/null
	
	sudo rm /var/www/html/payload.php > /dev/null

	echo -e "${GREEN}[+]${NC}	Installing MySQL"
	sudo apt-get install mysql-server -y > /dev/null

	sudo service apache2 restart > /dev/null

	dbpass=$(sudo cat /etc/mysql/debian.cnf | grep "password" | head -n 1 | cut -d '=' -f 2 | cut -d ' ' -f 2)

	dbuser=$(sudo cat /etc/mysql/debian.cnf | grep "user" | head -n 1 | cut -d "=" -f 2 | cut -d ' ' -f 2)

	echo -e "${GREEN}[+]${NC}	Populating database"
	mysql --user="${dbuser}" --password="${dbpass}" --database="mysql" --execute="DROP DATABASE IF EXISTS dvwadb;" 2> /dev/null

	mysql --user="${dbuser}" --password="${dbpass}" --database="mysql" --execute="DROP USER IF EXISTS 'dvwausr'@'127.0.0.1';" 2> /dev/null

	mysql --user="${dbuser}" --password="${dbpass}" --database="mysql" --execute="CREATE DATABASE dvwadb;" 2> /dev/null

	mysql --user="${dbuser}" --password="${dbpass}" --database="mysql" --execute="CREATE USER 'dvwausr'@'127.0.0.1' IDENTIFIED BY 'dvwa@123';" 2> /dev/null

	mysql --user="${dbuser}" --password="${dbpass}" --database="mysql" --execute="GRANT ALL PRIVILEGES ON dvwadb.* TO 'dvwausr'@'127.0.0.1';" 2> /dev/null

	echo -e "${GREEN}[+]${NC}	Installing PHP"
	
	sudo apt-get install php7.4 -y > /dev/null

	sudo apt-get install php7.4-fpm > /dev/null
	
	sudo apt-get install php7.4-mysql -y > /dev/null

	sudo apt-get install php7.4-gd -y > /dev/null

	mysql --user="${dbuser}" --password="${dbpass}" --database="mysql" --execute="source /var/www/html/mysql.sql;" 2> /dev/null

	sudo systemctl restart apache2 > /dev/null

	sudo /etc/init.d/apache2 restart > /dev/null

	sudo /etc/init.d/mysql restart > /dev/null

	sudo a2enmod proxy_fcgi setenvif > /dev/null

	sudo a2enconf php7.4-fpm > /dev/null

	sudo systemctl reload apache2 > /dev/null

	echo -e "${GREEN}[+]${NC}	Altering firewall configuration"
	
	yes | cp -rf /var/www/html/scripts/* ~
fi
