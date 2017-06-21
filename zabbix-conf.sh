#-------------------------------------------------
# author: Wendell Rocha <wendellrocha@outlook.com>
# github.com/WendellRocha
# 21/06/2017 at 12:00pm
# based on Adail Spinola code: github.com/zabbix-brasil/livrozabbix2014
#--------------------------------------------------

#!/bin/bash

CMDLINE=$0
MYUID=$(id | cut -d= -f2 | cut-d\( -f1)
if [ ! "MYUID" -eq 0 ] ; then
	echo "Você deve ser root para executar este script."
	echo "Execute o comando \"sudo $CMDLINE\""
	exit 1
fi

CONF_SERVER=/usr/local/etc/zabbix_server.conf

SENHA="zabbix"
DBNAME="zabbix"
DBUSER="zabbix"

mv $CONF_SERVER $CONF_SERVER.bkp
echo "DBUser=$DBUSER" > $CONF_SERVER
echo "DBPassword=$SENHA" >> $CONF_SERVER
echo "DBName=$DBNAME" >> $CONF_SERVER
echo "CacheSize=32M" >> $CONF_SERVER
echo "DebugLevel=3" >> $CONF_SERVER
echo "PidFile=/tmp/zabbix_server.pid" >> $CONF_SERVER
echo "LogFile=/tmp/zabbix_server.log" >> $CONF_SERVER
echo "Timeout=10" >> $CONF_SERVER

PATH_FPING=$(which fping);
echo "FpingLocation=$PATH_FPING" >> $CONF_SERVER

echo "Parâmetros setados no arquivo de configuração do Zabbix Server."

CONF_AGENT=/usr/local/etc/zabbix_agentd.conf

mv $CONF_AGENT $CONF_AGENT.bkp
echo "Server=127.0.0.1" > $CONF_AGENT
echo "StartAgents=5" >> $CONF_AGENT
echo "DebugLevel=3" >> $CONF_AGENT
echo "Hostname=$(hostname)" >> $CONF_AGENT
echo "PidFile=/tmp/zabbix_agentd.pid" >> $CONF_AGENT
echo "LogFile=/tmp/zabbix_agentd.log" >> $CONF_AGENT
echo "Timeout=10" >> $CONF_AGENT
echo "EnableRemoteCommands=1" >> $CONF_AGENT

echo "Parâmetros setados no arquivo de configuração do Zabbix Agent."

PHPFILE=/etc/php/7.0/apache2/php.ini

sed -i 's/max_execution_time/\;max_execution_time/g' $PHPFILE;
echo 'max_execution_time=300' >> $PHPFILE;
sed -i 's/max_input_time/\;max_input_time/g' $PHPFILE;
echo 'max_input_time=300' >> $PHPFILE;
sed -i 's/date.timezone/\;date.timezone/g' $PHPFILE;
echo 'date.timezone=America/Recife' >> $PHPFILE;
sed -i 's/post_max_size/\;post_max_size/g' $PHPFILE;
echo 'post_max_size=16M' >> $PHPFILE;

service apache2 restart

echo "O PHP foi configurado."

SOURCE=/home/zabbix/Zabbix/zabbix-3*
ZABBIX_WEB=/var/www/html/zabbix
mkdir $ZABBIX_WEB
cp -r $SOURCE/frontends/php/* $ZABBIX_WEB
chown -R www-data:www-data /var/www/

echo "A interface web do Zabbix foi instalada."

cp $SOURCE/misc/init.d/debian/zabbix-server /etc/init.d/
update-rc.d -f zabbix_server defaults
cp $SOURCE/misc/init.d/debian/zabbix-agent /etc/init.d/
update-rc.d -f zabbix-agent defaults

chmod 777 /var/www/html/zabbix/conf
