<!-- This should be the location of the title of the repository, normally the short name -->
# AIX Oracle Collection - power_aix_oracle

This repository contains ansible **power_aix_oracle** collection which is used for installing Oracle Single Instance database 19c on new AIX operating system and creates test database on AIX filesystem.

This collection automates Oracle 19c database installation and creation steps.

# Description

This playbook assumes the following:

     - That the user is familiar with Ansible and should have basic knowledge on YAML, for the purpose of running this playbook
     - That the user is familiar with Oracle Database Configuration
     - That the user is familiar with the AIX Operating system 
     - That the version of AIX is 7.2 TL4 SP1 or later. (It should work on other versions of AIX supported by the oracle database AIX OS requirements, but has not been tested). 
     - That the playbook assumes a **New AIX LPAR** for execution
     - That the targeted AIX LPAR for installing the Oracle single instance database will be referred within the rest of the document as the 'host' or 'managed host'.
     - That the version of Oracle Standalone Database is version 19.3.0.0. Later versions should work but have not been tested.

To get started with Ansible refer

https://docs.ansible.com/ansible/latest/user_guide/intro_getting_started.html

To get started with Oracle Database on AIX refer

https://docs.oracle.com/en/database/oracle/oracle-database/19/axdbi/index.html

https://www.ibm.com/support/pages/oracle-db-rac-19c-ibm-aix-tips-and-considerations

To get started with AIX refer

https://www.ibm.com/support/knowledgecenter/ssw_aix_72/navigation/welcome.html


# System Configuration

![System Topology](https://github.com/IBM/ansible-power-aix-oracle/blob/main/pics/System_Configuration.png)

Below is the system configuration that we have used for testing
We have used two servers one Linux_on_Power server used for running Ansible Engine and second one AIX server used for installation and configuration of oracle 19c Database software.

a)	Linux_on_Power server : 

               Operating System          : RHEL 8.2
               Ansible Engine Version    : 2.10.2
	       
   For Ansible Engine prerequisites refer to below link
    
   https://docs.ansible.com/ansible/latest/installation_guide/index.html
    
b)	AIX server :

               Operating System         : AIX72TL4SP01
               Oracle DB Version        : 19.3.0.0.0
               CPUs 		        : 4
               RAM		        : 64GB
               Storage Disks	        : 2X40GB (one rootvg and another for oracle DB) 
	       
   Refer below link to get details of minimum software/hardware requirements that are need to run oracle 19c database on AIX operating system
    
   https://docs.oracle.com/en/database/oracle/oracle-database/19/axdbi/oracle-database-installation-checklist.html

# Steps Followed

## 1.	Install Ansible Engine on your preferred operation system. We have installed and tested Ansible Engine on x86 server and Linux-on-Power server

   Refer : https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
    
   We have created a user "ansible" on LoP server and considered /home/ansible as working directory.

## 2.	Setup ssh Equivalence with managed host(AIX) server
    
   If this is a first time using ssh, then you probably haven’t created your ssh keys. To check go to ~/.ssh and see if id_rsa file exists. If not you must create      the ssh keys.
  To create the ssh keys, run the following:
 ```
  $ ssh-keygen
 ```
   Next copy the keys to the managed host.
 ```
  $ ssh-copy-id root@<managed_host>

  Eg: ssh-copy-id root@p227n241
 ```
  As per the last step instructions from the previous step, test that you can access the managed host:
```
  $ ssh 'root@p227n241'
```
## 3.	Preparing to run the oracle playbook

   * Download the Oracle AIX playbook ansible collection from ansible galaxy or github.
	
        https://galaxy.ansible.com/ibm/power_aix_oracle
	   
        https://github.com/IBM/ansible-power-aix-oracle
	
     To download from github you can follow below steps
     
```
     $ cd <working directory>
     $ git clone https://github.com/IBM/ansible-power-aix-oracle.git
     $ cd ansible-power-aix-oracle
```
   Download the power_aix_oracle tarball from ansible-galaxy and extract it to some directory for offline use or you can run the ansible-galaxy installation command:
```	   
	$ ansible-galaxy collection install ibm.power_aix_oracle
```
  The above command will install power_aix_oracle collection at location ~/.ansible/collections
  For more information regarding ansible collections refer below link
  
  https://docs.ansible.com/ansible/latest/user_guide/collections_using.html

 **###Before running the playbook you should do**

 -	Download the Oracle 19c software from OTN or oracle edelivery site
 
    https://edelivery.oracle.com/osdc/faces/SoftwareDelivery
    
    https://www.oracle.com/database/technologies/oracle19c-aix-193000-downloads.html

 -	Modify the Oracle Binary location path variable "oracledbaix19c" in file "playbooks/vars/oracle_params.yml"
 -	Check other Oracle related parameters in file "playbooks/vars/oracle_params.yml", modify it based on your need
 -	Based on your environment update resolv.conf and netsvc.conf files at "roles/preconfig/files/"
 -	There should be atleast one free disk available other than rootvg for Oracle DB Installation and test database will get created on JFS filesystem. 
        Make sure disk header information is clean. You can check the header information using "lquerypv -h /dev/hdiskX". 
	These free disks are used for staging oracle software binary and oracle datafiles.  
	Minimum 40GB disk storage is needed for running this Oracle playbook.

**###The collection contains below four roles**
 	
  **yum_python_install** : This role is used for configuring yum and python on AIX managed host. 
  
  **preconfig** : This role will perform AIX configuration tasks that are needed for oracle installation
  
  **oracle_install** : This role performs oracle binary installation
  
  **oracle_createdb** : This role creates test database "orcl" using oracle dbca utility


Inside power_aix_oracle collection go to "playbooks" directory

Create/Update ansible.cfg and inventory files in collections "playbooks" directory. On managed host(AIX) "/tmp" filesystem is used for ansible remote temporary  activities. Since we need to transfer and extract oracle binary software files, the playbook will automatically set the /tmp filesystem size to 12G. "inventory" file should contain the list on managed hosts (AIX lpars).

  Example ansible.cfg file 
```
 $ cat ansible.cfg
   [defaults]
   inventory = ./inventory
   interpreter_python = /usr/bin/python
   remote_user = root
   host_key_checking = False
   remote_tmp = /tmp/.ansible
   callback_whitelist = profile_tasks
```
  Example inventory file
```  
  $ cat inventory
    p227n241
```

## 4.	Execute playbook using below command

        First execute the bootstrap playbook for installing yum and python on AIX host

```
        $ cat demo_bootstrap.yml
          - hosts: all
            gather_facts: no
            roles:
              - role: yum_python_install
                vars:
                  download_dir: "~"
                  target_dir: "/tmp/.ansible.cpdir"
                tags: bootstrap


        $ ansible-playbook demo_bootstrap.yml

```

        Once yum and python got configured on managed host then you can run below playbook for installing oracle binary and for creating test database
```
        $ cat demo_play_aix_oracle.yml
          - hosts: all
            gather_facts: yes
            vars_files: vars/oracle_params.yml
            roles:
              - role: preconfig
                tags: preconfig
              - role: oracle_install
                tags: oracle_install
              - role: oracle_createdb
                tags: oracle_createdb


	$ ansible-playbook demo_play_aix_oracle.yml
```

You can also run each role separately using ansible tags

To run only preconfig tasks
```
     $ ansible-playbook demo_play_aix_oracle.yml --tags "preconfig"
```
If you want to run preconfig and oracle_install tasks
```
      $ ansible-playbook demo_play_aix_oracle.yml --tags "preconfig,oracle_install"
```
If you want to skip database creation tasks then you can also try
```
     $ ansible-playbook demo_play_aix_oracle.yml --skip-tags="oracle_createdb"
```

# Collection Roles

As discussed earlier this collection has four roles


1)	**yum_python_install** :  This role contains two tasks one installation of yum and other one is installation of python. The yum and python can also be installed using power_aix collection which is available at ansible galaxy and GIT hub.

https://ibm.github.io/ansible-power-aix/index.html            

https://galaxy.ansible.com/ibm/power_aix

https://github.com/IBM/ansible-power-aix


  The configuration yum/python on AIX can be done is two ways
  a)	Option1 – using power_aix ansible collection
  b)	Option2 – Manual method

  Steps for both methods are mentioned in detail in Appendix section

2)	**preconfig** :

	- Expand /var and /opt filesystems
	- Running cfgmgr to discover new devices
	- Changes /tmp to 12G size, holds ansible temp files
	- Changing ulimits for default user to unlimited
	- Setting DNS
	- Setting DNS order
	- Checking /etc/hosts file on managed host and adding entry if needed
	- Changes maxuproc
	- Checking and setting iocp attribute to "available". Rebooting the lpar if needed


3)	**oracle_install**:
	
	- Detecting oracle version to install
	- Listing available disks
	- Creating volume group using all available disks
	- Creating oracle groups and user
	- Creating and mounting filesystem for oracle staging
	- Updating .profile file with Oracle env details
	- Generating oracle response file
	- Create directories for ORACLE_HOME and ORACLE_BASE
	- Changing the permissions
	- Copying oracle Single instance source files
	- Running rootpre.sh
	- Install-home-db | Install Oracle Database Server
	- Running orainstRoot.sh
	- Running root.sh


4)	**oracle_createdb**:

        - Check /etc/oratab file for DB existence
        - Create and mount filesystems for datafiles and redo logfiles
        - Check and changing permissions of Filesystems
        - Generate Database creation template file
        - Generate database creation script for  oracle version
        - Creating database
        - Creating and configuring oracle listener
        - Check Oracle PMON background process status

# Appendix

In this section we will discuss different ways of installing yum/python on AIX
On the AIX managed host, check if yum and python are installed.
```
$ which yum
no yum in /usr/bin /etc /usr/sbin /usr/ucb /usr/bin/X11 /sbin /usr/java8_64/jre/bin /usr/java8_64/bin
$ which python
no python in /usr/bin /etc /usr/sbin /usr/ucb /usr/bin/X11 /sbin /usr/java8_64/jre/bin /usr/java8_64/bin
```
 if not, The following procedures will help you install the components.

## Option A, Using the ansible playbook collection: ansible-power-aix to install missing components
•	Install and configure yum, python on the managed host. You can do this using anisble power-aix collection. Power-aix collection can also perform other AIX admin tasks too.

      	https://ibm.github.io/ansible-power-aix/index.html 
	
      	https://galaxy.ansible.com/ibm/power_aix
	
        https://github.com/IBM/ansible-power-aix
             
              
 
Download the power-aix tarball from ansible-galaxy for offline use or you can run the installation command:
```
	ansible-galaxy collection install ibm.power_aix
```
 
The above command will install power_aix collection at location ~/.ansible/collections
For more information regarding ansible collections refer below link

https://docs.ansible.com/ansible/latest/user_guide/collections_using.html
    
a)	Prepare bootstrap.yml using "~/.ansible/collections/ansible_collections/ibm/power_aix/playbooks/demo_bootstrap.yml"
```
$ cat bootstrap.yml
---
- name: "Bootstrap Yum on AIX"
  hosts: all
  gather_facts: no
  collections:
  - ibm.power_aix
  tasks:

# CHECK for Yum on inventory host
  - import_role:
      name: power_aix_bootstrap
    vars:
      pkgtype: "yum"
      download_dir: "~"
      target_dir: "/tmp/.ansible.cpdir"

# INSTALL / UPDATE Python on inventory host
- name: "Bootstrap Python on AIX"
  hosts: all
  gather_facts: no
  collections:
  - ibm.power_aix
  tasks:

  - import_role:
      name: power_aix_bootstrap
    vars:
      pkgtype: "python"
```

b)	Prepare ansible.cfg, inventory files for playbook execution. "p227n241" is AIX managed host  mentioned in inventory file. Update the "roles_path" to power-aix collection roles directory.

```
$ cat ansible.cfg
[defaults]
inventory = ./inventory
interpreter_python = /usr/bin/python
remote_user = root
host_key_checking = False
remote_tmp = /tmp/.ansible
roles_path    = /home/ansible/.ansible/collections/ansible_collections/ibm/power_aix /roles
```

```
$ cat inventory
p227n241
```
c)	Executing bootstrap playbook
```
    $ ansible-playbook bootstrap.yml
```
d)	Bootstrap playbook creates below files in user home directory. You can do a cleanup if needed
```
#+ cleanup of files created in $HOME
(cd $HOME; rm -f rpm.rte yum_bundle.tar yum_installer.sh
```
## Option B, installing them manually onto the managed host.
 
https://public.dhe.ibm.com/aix/freeSoftware/aixtoolbox/ezinstall/ppc/

Please go through the README-yum file for instructions

https://public.dhe.ibm.com/aix/freeSoftware/aixtoolbox/ezinstall/ppc/README-yum


## Resources

For **guides** and **reference**, please visit the [Documentation](https://github.com/IBM/ansible-power-aix-oracle/tree/main/docs/) site.

## License

[Apache License 2.0] (http://www.apache.org/licenses/)
## Copyright

© Copyright IBM Corporation 2021

