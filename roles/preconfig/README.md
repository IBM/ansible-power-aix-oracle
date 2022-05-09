# Ansible Role: preconfig 
 This role performs AIX configuration tasks that are needed for oracle installation
## Requirements
New AIX partition/VM
None.

## Role Variables
Variables are defined at playbooks/vars/oracle_params.yml
## Dependencies

None.

## Example Playbook

    - hosts: aix
      include_role:
        name: preconfig 

## Copyright
© Copyright IBM Corporation 2020
