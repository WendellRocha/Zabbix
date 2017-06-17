#------------------------------------------------
# author: Wendell Rocha <wendellrocha@outlook.com>
# github.com/WendellRocha
# 06/15/2017 at 12:14
# based on Adail Spinola code: github.com/zabbix-brasil/livrozabbix2014
#------------------------------------------------

#!/bin/bash

CMDLINE=$0

MYUID=$(id | cut -d= -f2 | cut -d\( -f1)
if [ ! "$MYUID" -eq 0 ] ; then
        echo "voce deve ser root para executar este script."
        echo "execute o comando \"sudo $CMDLINE\""
        exit 1
fi

CONF_SERVER=/usr/local/etc/zabbix_server.conf

SENHA="zabbix";
NOMEBANCO="zabbix";
USUARIODB="zabbix";

mv $CONF_SERVER $CONF_SERVER.ori.$$
echo "DBUser=$USUARIODB" > $CONF_SERVER
echo "DBPassword=$SENHA" >> $CONF_SERVER
echo "DBName=$NOMEBANCO" >> $CONF_SERVER
echo "CacheSize=32M" >> $CONF_SERVER

echo "DebugLevel=3" >> $CONF_SERVER
echo "PidFile=/tmp/zabbix_server.pid" >> $CONF_SERVER
echo "LogFile=/tmp/zabbix_server.log" >> $CONF_SERVER
echo "Timeout=10" >> $CONF_SERVER

PATH_FPING=$(which fping);
echo "FpingLocation=$PATH_FPING" >> $CONF_SERVER

echo "O arquivo de configuracao do Zabbix Server esta em $CONF_SERVER"

CONF_AGENTE=/usr/local/etc/zabbix_agentd.conf

mv $CONF_AGENTE $CONF_AGENTE.ori.$$

echo "Server=127.0.0.1" > $CONF_AGENTE
echo "StartAgents=3" >> $CONF_AGENTE
echo "DebugLevel=3" >> $CONF_AGENTE
echo "Hostname=$(hostname)" >> $CONF_AGENTE
echo "PidFile=/tmp/zabbix_agentd.pid" >> $CONF_AGENTE
echo "LogFile=/tmp/zabbix_agentd.log" >> $CONF_AGENTE
echo "Timeout=10" >> $CONF_AGENTE
echo "EnableRemoteCommands=1" >> $CONF_AGENTE

echo "O arquivo de configuracao do Zabbix Agentd esta em $CONF_AGENTE"

PHPFILE=/etc/php/7.0/apache2/php.ini

cp $PHPFILE $PHPFILE.ori.$$
sed -i 's/max_execution_time/\;max_execution_time/g' $PHPFILE;
echo ' max_execution_time=300'>> $PHPFILE;
sed -i 's/max_input_time/\;max_input_time/g' $PHPFILE;
echo 'max_input_time=300' >> $PHPFILE;
sed -i 's/date.timezone/\;date.timezone/g' $PHPFILE;
echo ' date.timezone=America/Sao_Paulo' >> $PHPFILE;
sed -i 's/post_max_size/\;post_max_size/g' $PHPFILE;
echo ' post_max_size=16M' >> $PHPFILE;

service apache2 restart

echo "O PHP foi configurado no arquivo $PHPFILE"

SOURCE_DIR="/home/zabbix/Zabbix/zabbix-3*";

ZABBIX_WEB_DIR=/var/www/html/zabbix
mkdir -p $ZABBIX_WEB_DIR > /dev/null 2>&1
cp -r $SOURCE_DIR/frontends/php/* $ZABBIX_WEB_DIR
chown -R www-data:www-data /var/www/

echo "A interface web do Zabbix foi instalada em $ZABBIX_WEB_DIR"

cp $SOURCE_DIR/misc/init.d/debian/zabbix-server /etc/init.d/
update-rc.d -f zabbix-server defaults
cp $SOURCE_DIR/misc/init.d/debian/zabbix-agent /etc/init.d/
update-rc.d -f zabbix-agent defaults

chmod 777 /var/www/html/zabbix/conf/