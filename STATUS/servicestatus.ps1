<#
#
# Script de monitoramento de serviço!
#
# Autor: João Kienen
# Data de criação: 12/04/2021
#
# Descrição: Script de monitoramento de estado de serviço com o zabbix!
# Description: Service state monitoring script with zabbix!
# Validação com arquivo zabbix: /etc/zabbix/zabbix_agentd.conf
#>

if (get-service "YourService" | where-object {$_.Status -eq 'Running'}) {
  Write "0"
} 
else {
  Write "1"
}
