{{ora_home}}/bin/dbca -silent -createDatabase -templateName /tmp/{{ora_sid}}.{{ansible_date_time.epoch}}.dbt -createAsContainerDatabase false -sid {{ora_sid}}  -memoryPercentage 40 -emConfiguration LOCAL -characterSet {{ora_character_set}} -responseFile NO_VALUE -gdbname {{ora_sid}} << EOPASS
{{ora_pwd}}
{{ora_pwd}}
{{ora_pwd}}
{{ora_pwd}}
EOPASS


# Creating listenet on port 1521
#{{ora_home}}/bin/netca -silent -responsefile {{ora_home}}/assistants/netca/netca.rsp
#{{ora_home}}/bin/lsnrctl start LISTENER

