# Ansible Role: oracle_createdb 
 This role creates test database using dbca utility from oracle home
## Requirements
None.

## Role Variables
Variables are defined at playbooks/vars/oracle_params.yml 
## Dependencies
oracle_install

## Example Playbook

    - hosts: aix
      include_role:
        name: oracle_createdb 

## Copyright
© Copyright IBM Corporation 2020
