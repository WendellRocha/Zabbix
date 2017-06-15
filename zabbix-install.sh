#------------------------------------------------
# author: Wendell Rocha <wendellrocha@outlook.com>
# github.com/WendellRocha
# 06/15/2017 at 12:14
# basede on Adail Spinola code: github.com/zabbix-brasil/livrozabbix2014
#------------------------------------------------

#!/bin/bash

# Detecta se eh um usuario com poderes de root que esta executando o script
CMDLINE=$0;
MYUID=$(id | cut -d= -f2 | cut -d\( -f1)
if [ ! "$MYUID" -eq 0 ] ; then
        echo "voce deve ser root para executar este script."
        echo "execute o comando \"sudo $CMDLINE\""
        exit 1
fi

## Verificando se foi passado algum parametro
if [ "$#" == "0" ]
then
       echo "Voce precisa informar a versao do Zabbix a ser baixada. Ex.: 2.4.3".
       echo "O script seria chamado assim: sudo $0 2.4.3"	
       exit 1
fi

apt update
apt upgrade -y
apt dist-upgrade -y
apt install -y build-essential libopenipmi-dev snmp apache2 php libapache2-mod-php php-gd fping curl
apt install -y libsnmp-dev libcurl4-openssl-dev vim libssh2-1-dev libssh2-1 libcurl3-gnutls-dev 
apt install -y libcurl-dev php-mbstring php-xml php-net-socket php-ldap php-curl libopenipmi-dev libcurl4-gnutls-dev
apt install -y python-software-properties mysql-server mysql-client libmysqld-dev libpqxx-dev php-mysql   

VERSAO=$1;

echo "Obtendo os arquivos fontes do Zabbix $VERSAO ." 
wget "http://ufpr.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/$VERSAO/zabbix-$VERSAO.tar.gz"

echo "Descompactando os arquivos fontes do Zabbix..." 
tar -xzvf "zabbix-$VERSAO.tar.gz"
SOURCE = "zabbix-$VERSAO"

cd $SOURCE
echo "Iniciando a compilação dos binários do Zabbix..."
./configure --enable-server --enable-agent --with-mysql --with-net-snmp --with-libcurl --with-libxml2 --with-openipmi
make install


echo "Configurando o Zabbix Server e o Zabbix Agent..."
SENHADB="zabbix"
DBUSER="zabbix"
DBNAME="zabbixdb"
CONF_SERVER="/usr/local/etc/zabbix_server.conf"

mv $CONF_SERVER $CONF_SERVER.bkp
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

CONF_AGENTE=/usr/local/etc/zabbix_agentd.conf

mv $CONF_AGENTE $CONF_AGENTE.bkp

echo "Server=127.0.0.1" > $CONF_AGENTE
echo "StartAgents=3" >> $CONF_AGENTE
echo "DebugLevel=3" >> $CONF_AGENTE
echo "Hostname=$(hostname)" >> $CONF_AGENTE
echo "PidFile=/tmp/zabbix_agentd.pid" >> $CONF_AGENTE
echo "LogFile=/tmp/zabbix_agentd.log" >> $CONF_AGENTE
echo "Timeout=10" >> $CONF_AGENTE
echo "EnableRemoteCommands=1" >> $CONF_AGENTE


echo "Configurando o PHP..."
PHPFILE=/etc/php/7.0/apache2/php.ini

mv $PHPFILE $PHPFILE.bkp

sed -i 's/max_execution_time/\;max_execution_time/g' $PHPFILE;
echo ' max_execution_time=300'>> $PHPFILE;
sed -i 's/max_input_time/\;max_input_time/g' $PHPFILE;
echo 'max_input_time=300' >> $PHPFILE;
sed -i 's/date.timezone/\;date.timezone/g' $PHPFILE;
echo ' date.timezone=America/Recife' >> $PHPFILE;
sed -i 's/post_max_size/\;post_max_size/g' $PHPFILE;
echo ' post_max_size=16M' >> $PHPFILE;

service apache2 restart

echo "Instalando o fronted do Zabbix"

mkdir /var/www/html/zabbix/
cp -a . $SOURCE/frontends/php/ /var/www/html/zabbix/
chown -R www-data:www-data /var/www/html/zabbix/
