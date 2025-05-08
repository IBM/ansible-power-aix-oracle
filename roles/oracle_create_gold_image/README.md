# Ansible Role: oracle_install 
 This role performs oracle database and grid home gold image creation
## Requirements
Single instance Grid and Database home should be installed already

## Role Variables
Variables are defined at playbooks/vars/gi_oracle_params.yml  

## Dependencies
None

## Example Playbook

    - hosts: aix
      include_role:
        name: oracle_create_gold_image

## Copyright
© Copyright IBM Corporation 2025
