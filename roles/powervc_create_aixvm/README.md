# Ansible Role: oracle_install 
 This role creates PowerVC VM for oracle Single Instance installation 
## Requirements
None.

## Role Variables
Variables are defined at playbooks/vars/powervc_oracle_params.yml  
## Dependencies
preconfig 

## Example Playbook

    - hosts: aix
      include_role:
        name: powervc_create_aixvm 

## Copyright
© Copyright IBM Corporation 2020
