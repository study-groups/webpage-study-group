ghost-install(){
cat <<EOF
sudo apt-get install mysql-server

# To set a password, run
sudo mysql

# Now update your user with this command
# Replace 'password' with your password, but keep the quote marks!
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';

# Then exit MySQL
quit

# and login to your Ubuntu user again
su - <user>

npm install ghost-cli@latest -g

ghost install local
EOF
}

ghost-node-activate(){
  nvm use --lts

}

ghost-mysql-reset-password(){
cat <<EOF
systemctl stop mysql
mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld
/usr/sbin/mysqld --skip-grant-tables --skip-networking &
mysql -u root

mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected, 6 warnings (0.02 sec)

mysql> SET PASSWORD FOR root@'localhost' = PASSWORD('linuxconfig');
mysql> quit

kill %1

systemctl start mysql
EOF
}
