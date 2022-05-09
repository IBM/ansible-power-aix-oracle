# Ansible Role: oracle_install 
 This role performs oracle single instance database  installation
## Requirements
None.

## Role Variables
Variables are defined at playbooks/vars/oracle_params.yml  
## Dependencies
preconfig 

## Example Playbook

    - hosts: aix
      include_role:
        name: oracle_install 

## Copyright
© Copyright IBM Corporation 2020
