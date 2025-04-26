#!/bin/ksh93

{{ ora_home }}/bin/dbca -silent -createDatabase -templateName {{ files_dir }}/{{ ora_sid }}.dbt -createAsContainerDatabase false -sid {{ ora_sid }} -memoryPercentage 40 -emConfiguration LOCAL -characterSet {{ ora_character_set }} -responseFile NO_VALUE -gdbname {{ ora_sid }} << EOPASS
{{ora_pwd}}
{{ora_pwd}}
{{ora_pwd}}
{{ora_pwd}}
EOPASS
