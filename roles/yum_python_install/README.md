# Ansible Role: yum_python_install

This role is used to install yum and python on AIX operating system

## Requirements

None.

## Role Variables

Available variables are listed below, along with default values:

    download_dir (optional, str, ~)

Specifies the temporary download location for install scripts and packages. The location resides on the Ansbile control node.

    target_dir (optional, str, /tmp/.ansible.cpdir)

Specifies the target location (per inventory host) for copying and restoring package files and metadata. If the target location does not exist, then a temporary filesystem is created using the target_dir as the mount point.  Upon role completion, the target location is removed.

## Dependencies

None.

## Example Playbook

    - hosts: aix
      gather_facts: no
	  roles:
        - role: yum_python_install
          vars:
            download_dir: "~"
            target_dir: "/tmp/.ansible.cpdir"
          tags: bootstrap


## Copyright
© Copyright IBM Corporation 2020
