# Ansible Role: oracle_install 
 This role performs oracle single instance database  deinstallation
## Requirements
Single database home should be installed with or without grid

## Role Variables
Variables are defined at playbooks/vars/deinstall_oracle_params.yml  

## Dependencies
None

## Example Playbook

    - hosts: aix
      include_role:
        name: oracle_deinstall 

## Copyright
© Copyright IBM Corporation 2025
