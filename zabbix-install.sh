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

