$mysql_command --defaults-file=$config $defaults_extra_file $no_defaults $argscl <<EOF
CREATE USER 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
GRANT ALL ON *.* TO 'root'@'%';
FLUSH PRIVILEGES;
EOF
