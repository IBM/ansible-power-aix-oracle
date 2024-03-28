<!-- This should be the location of the title of the repository, normally the short name -->
# AIX Oracle Collection - power_aix_oracle

This repository contains ansible **power_aix_oracle** collection which is used for installing Oracle Single Instance database 19c on new AIX operating system and creates test database on AIX filesystem and on Oracle ASM.

This collection automates Oracle 19c database installation and creation steps. Tested playbook on AIX 73 and PowerVS AIX partition. Also tested playbook using Ansible Automation Platform 2, you can find the steps in below sections.

# Description

This playbook assumes the following:

     - That the user is familiar with Ansible and should have basic knowledge on YAML, for the purpose of running this playbook
     - That the user is familiar with Oracle Database Configuration
     - That the user is familiar with the AIX Operating system 
     - That the version of AIX is 7.2 TL4 SP1 or later. (It should work on other versions of AIX supported by the oracle database AIX OS requirements, but has not been tested). 
     - That the playbook assumes a **New AIX LPAR** for execution
     - That the targeted AIX LPAR for installing the Oracle single instance database will be referred within the rest of the document as the 'host' or 'managed host'.
     - That the version of Oracle Standalone Database is version 19.3.0.0 + RU (Optional)
     - uses ibm.power_aix collection modules.

To get started with Ansible refer

https://docs.ansible.com/ansible/latest/user_guide/intro_getting_started.html

To get started with Oracle Database on AIX refer

https://docs.oracle.com/en/database/oracle/oracle-database/19/axdbi/index.html

https://www.ibm.com/support/pages/oracle-db-rac-19c-ibm-aix-tips-and-considerations

To get started with AIX refer

https://www.ibm.com/support/knowledgecenter/ssw_aix_72/navigation/welcome.html


# System Configuration

![System Topology](https://github.com/IBM/ansible-power-aix-oracle/blob/main/pics/System_Configuration.png)

For detail README which specifies steps for executing the playbook listed in below document

## Resources

For **guides** and **reference**, please visit the [Documentation](https://github.com/IBM/ansible-power-aix-oracle/tree/main/docs/) site.

## License

[Apache License 2.0] (http://www.apache.org/licenses/)
## Copyright

© Copyright IBM Corporation 2021

