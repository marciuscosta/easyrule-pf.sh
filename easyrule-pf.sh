#!/bin/sh
# Script para adicionar IPs bloqueados pelo Wazuh no pfSense dentro do aliase "EasyRuleBlockHosts"
# Expect: srcip
# Author: Marcius da C. Silveira
# Last modified: Mar 3, 2022

ACAO=$1
USUARIO=$2
IP=$3


# logando as atividades desse script
echo "`date` $0 $1 $2 $3 $4 $5" >> /var/ossec/logs/active-responses.log


# Erro se o IP nao for mencionado nos argumentos
if [ "x${IP}" = "x" ]; then
   echo "$0: Falta o IP no terceiro argumento <acao> <usuario> (IP)"
   exit 1;
fi


# Coletando os nomes das interfaces do pfSense
INTF=`/usr/local/bin/xmllint --xpath 'pfsense/interfaces/child::*' /conf/config.xml | grep '^<' | tr -d '<' | tr -d '>'`
QTDINTF=`echo ${INTF} | wc -w`
# a ACAO sera feita para cada interface coletada acima
# caso deseje executar a ACAO para interfaces especificas, especifique elas na varialvel INTF colocando espacos entre cada uma, por exemplo:
# INTF="wan lan"
while [ ${QTDINTF} != 0 ]; do
	IF=`echo ${INTF} | cut -d ' ' -f ${QTDINTF}`
	# Se o argumento ACAO for "add"
	if [ "x${ACAO}" = "xadd" ]; then
		/usr/local/bin/easyrule	block $IF "${IP}"
	# Se o argumento ACAO for "delete"
	elif [ "x${ACAO}" = "xdelete" ]; then
		/usr/local/bin/easyrule unblock $IF "${IP}"

	# Se o argumento ACAO for invalido
	else
	   echo "$0: acao invalida: ${ACAO}"
	fi
 	QTDINTF=$((QTDINTF-1))
done

exit 1;
