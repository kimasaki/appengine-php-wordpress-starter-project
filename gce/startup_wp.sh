# WP Statrup script for Google Compute Engine (https://cloud.google.com/products/compute-engine/)
# you can start WP GCE instace by the following command. 
# gcutil --project=<your project name> addinstance <instance name> --metadata=project_id:<your project id> --metadata=sql_pwd:<mysql password> --metadata=startup-script-url:<location of script>

mkdir /home/wp
cd /home/wp
rm -fr work
mkdir work
cd work
wget https://commondatastorage.googleapis.com/appengine-sdks/featured/google_appengine_1.9.3.zip
SQL_PWD=$(curl http://metadata/computeMetadata/v1beta1/instance/attributes/sql_pwd)
echo mysql-server mysql-server/root_password password "$SQL_PWD"| sudo debconf-set-selections
echo mysql-server mysql-server/root_password_again password "$SQL_PWD" | sudo debconf-set-selections
sudo apt-get --yes --force-yes install make unzip gcc libmysqlclient-dev libxml2-dev bzip2 git libmysqlclient-dev libxml2-dev mysql-server-5.5
unzip google_appengine_1.9.3.zip
sudo apt-get --yes --force-yes install gcc 
wget --trust-server-names http://us2.php.net/get/php-5.4.25.tar.bz2/from/us1.php.net/mirror
tar -xvf php-5.4.25.tar.bz2
cd php-5.4.25
./configure --prefix=$PWD/installdir --enable-bcmath --with-mysql
make install
cd ..
git clone --recursive https://github.com/GoogleCloudPlatform/appengine-php-wordpress-starter-project.git
cd appengine-php-wordpress-starter-project
PROJECT_ID=$(curl http://metadata/computeMetadata/v1beta1/instance/attributes/project_id)
sed -i "s/your-project-id/$PROJECT_ID/g" app.yaml 
sed -i "s/your-project-id/$PROJECT_ID/g" wp-config.php
sed -i "s/password/$SQL_PWD/" wp-config.php
sh move_files_after_editing.sh
mysql -h 127.0.0.1 -u root --password="$SQL_PWD" -e "CREATE DATABASE IF NOT EXISTS wordpress_db;"
cd work
echo 'execute the following command to start local server "google_appengine/dev_appserver.py --php_executable_path=php-5.4.25/installdir/bin/php-cgi appengine-php-wordpress-starter-project --host=0.0.0.0"'
