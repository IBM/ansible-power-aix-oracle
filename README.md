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
     - That the version of Oracle Standalone Database is version 19.3.0.0
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
    
   If this is a first time using ssh, then you probably havent created your ssh keys. To check go to ~/.ssh and see if id_rsa file exists. If not you must create the ssh keys.
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
Note: You can also mention the username and password in inventory file instead of ssh equivalence. If you are using Ansible Controller(Tower), you can save the credentials.

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

###  Before running the playbook you should do

 -      This collection uses ibm.power_aix collection modules like filesystem, devices, lvg, reboot and mount. Install latest version(1.4.0 or later) from galaxy
        "ansible-galaxy collection install ibm.power_aix"

 -	Download the Oracle 19c software from OTN or oracle edelivery site
 
    https://edelivery.oracle.com/osdc/faces/SoftwareDelivery
    
    https://www.oracle.com/database/technologies/oracle19c-aix-193000-downloads.html

 -	Modify the Oracle Binary location path variable "oracledbaix19c" in file "vars/oracle_params.yml"
 -      This collection supports creating oracle DB on AIX JFS and on Oracle ASM. For grid installation set the boolean variable "grid_asm_flag" to true in oracle_params.yml file
 -	Check other Oracle related parameters in file "vars/oracle_params.yml", modify it based on your need
 -	Based on your environment update resolv.conf and netsvc.conf files at "roles/preconfig/files/"
 -	There should be atleast one free disk available other than rootvg for Oracle DB Installation and test database will get created on JFS filesystem. 
        Make sure disk header information is clean. You can check the header information using "lquerypv -h /dev/hdiskX". 
	These free disks are used for staging oracle software binary and oracle datafiles.  
	Minimum 40GB disk storage is needed for running this Oracle playbook. For Grid Software and DB software you may need minimum 60G disk storage
 -      The rootvg disk should be atleast 30GB, we will be using /tmp for ansible remote location(~8GB) and assumes paging device part of rootvg

Note : When Running playbook on PowerVS AIX VM we noticed that by default rootvg (boot) disk size is 20G, Before running the playbook we need to extend the rootvg size by adding new disk. For example "extendvg -f rootvg hdiskX"
 
###  The collection contains below three roles
 	
  **preconfig** : This role will perform AIX configuration tasks that are needed for oracle installation
  
  **oracle_install** : This role performs oracle binary installation
  
  **oracle_createdb** : This role creates test database "orcl" using oracle dbca utility


Go to power_aix_oracle collection directory

Create/Update ansible.cfg and inventory files in collection directory. On managed host(AIX) "/tmp" filesystem is used for ansible remote temporary  activities. Since we need to transfer and extract oracle binary software files, the playbook will automatically set the /tmp filesystem size to 8G. "inventory" file should contain the list on managed hosts (AIX lpars).

  Example ansible.cfg file 
```
  $ cat ansible.cfg
    [defaults]
    inventory = ./inventory
    # interpreter_python = /usr/opt/freeware/bin/python3    # AIX 7.3 supports python3
    interpreter_python = /usr/bin/python
    remote_user = root
    host_key_checking = False
    remote_tmp = /tmp/.ansible
    [ssh_connection]
    ssh_args = -o ForwardAgent=yes -o ControlPersist=30m -o ServerAliveInterval=45 -o ServerAliveCountMax=10
```
  Example inventory file
```  
  $ cat inventory
    p227n241
```

## 4.	Execute playbook using below command

    If yum and python is not configured on AIX system, first execute the bootstrap playbook from ibm.power_aix collection, refer to Appendix section for steps.

    Note: AIX 73 uses dnf for installing the packages by default it will be installed at /opt/freeware/bin. If not, use "demo_bootstrap_dnf.yml" from ibm.power_aix collection for configuring dnf and python3

    Once yum and python got configured on managed host(i.e., AIX server) then you can run below playbook for installing oracle binary and creating test database

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

As discussed earlier this collection has three roles

1)	**preconfig** :

	- Expand /var and /opt filesystems
	- Running cfgmgr to discover new devices
	- Changes /tmp to 12G size, holds ansible temp files
	- Changing ulimits for default user to unlimited
	- Setting DNS
	- Checking /etc/hosts file on managed host and adding entry if needed
	- Changes maxuproc
        - Set OS paging size  
        - Do VG disks and ASM disk validations 
	- Checking and setting iocp attribute to "available". Rebooting the lpar if needed


2)	**oracle_install**:
	
        - Detecting oracle version to install
        - Create Oracle groups and user
        - Creating volume group for ORACLE_HOME
        - Creating and mounting filesystem for ORACLE_HOME
        - Creating oracle installation directories
        - If grid option selected install Standalone Grid Software
        - Updating .profile file with Oracle env details
        - Generating oracle response file and install Oracle DB Software
        - Run root scripts

3)	**oracle_createdb**:

        - Check /etc/oratab file for DB existence
        - Check /etc/oratab file for DB existence
        - If grid option selected create database on ASM storage
        - For JFS DB, create VG and mount filesystems
        - Generate Database creation template file
        - Generate database creation script
        - Creating database
        - For JFS DB, Creating and configuring oracle listener
        - Check Oracle PMON background process status

## Executing Oracle collection using Ansible Automation Platform 2 (AAP2)

  Ansible Automation Platform 2 is fully restructured for a hybrid cloud-native world and enables to execute automation in containerized environments.

  Here in this section we will show to create the containerized image and execute the playbook using execution environment(Containerized image).

  At first using "ansible-builder" create Containerfile or Dockerfile and then build the Container Image

  For more info regarding ansible-builder refer to below 
  https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.0-ea/html-single/ansible_builder_guide/index


```
$ cat execution-environment.yml
---
version: 1

build_arg_defaults:
  EE_BASE_IMAGE: 'quay.io/ansible/ansible-runner:latest'

dependencies:
  galaxy: requirements.yml

additional_build_steps:
  append:
   - RUN mkdir -p /zips/oraclesw19c/
   - COPY oraclesw19c/AIX.PPC64_193000_db_home.zip /zips/oraclesw19c/
   - COPY oraclesw19c/AIX.PPC64_193000_grid_home.zip /zips/oraclesw19c/
```

```
cat requirements.yml
---
collections:
  - ibm.power_aix
```
After creating execution-environment.yml file use ansible-builder to create Dockerfile or Containerfile

```
$ ansible-builder create -f execution-environment.yml
Complete! The build context can be found at: /var/lib/awx/test/oracle/context
```

Displaying the content of container or docker file

```
$ cd context
$ cat Containerfile
ARG EE_BASE_IMAGE=quay.io/ansible/ansible-runner:latest
ARG EE_BUILDER_IMAGE=quay.io/ansible/ansible-builder:latest

FROM $EE_BASE_IMAGE as galaxy
ARG ANSIBLE_GALAXY_CLI_COLLECTION_OPTS=
USER root

ADD _build /build
WORKDIR /build

RUN ansible-galaxy role install -r requirements.yml --roles-path /usr/share/ansible/roles
RUN ansible-galaxy collection install $ANSIBLE_GALAXY_CLI_COLLECTION_OPTS -r requirements.yml --collections-path /usr/share/ansible/collections

FROM $EE_BUILDER_IMAGE as builder

COPY --from=galaxy /usr/share/ansible /usr/share/ansible

RUN ansible-builder introspect --sanitize --write-bindep=/tmp/src/bindep.txt --write-pip=/tmp/src/requirements.txt
RUN assemble

FROM $EE_BASE_IMAGE
USER root

COPY --from=galaxy /usr/share/ansible /usr/share/ansible

COPY --from=builder /output/ /output/
RUN /output/install-from-bindep && rm -rf /output/wheels
RUN mkdir -p /zips/oraclesw19c/
COPY oraclesw19c/AIX.PPC64_193000_db_home.zip /zips/oraclesw19c/
COPY oraclesw19c/AIX.PPC64_193000_grid_home.zip /zips/oraclesw19c/
```

Next manually copy oracle binary software directory to context directory. In next release we will have a nfs option for staging the oracle binary files, this will eliminate the copy of binary files to container.

```
$ cp /zips/oraclesw19c /var/lib/awx/test/oracle/context
```

Using ansible-builder build the execution environment

```
$ cd /var/lib/awx/test/oracle

$ ansible-builder build -t oracle_aix_ee
Running command:
  podman build -f context/Containerfile -t oracle_aix_ee context
Complete! The build context can be found at: /var/lib/awx/test/oracle/context

$ podman images
REPOSITORY                       TAG         IMAGE ID      CREATED             SIZE
localhost/oracle_aix_ee          latest      8029c770954b  About a minute ago  7.91 GB
<none>                           <none>      037f938762cb  2 minutes ago       914 MB
<none>                           <none>      61d13beee50b  3 minutes ago       835 MB
quay.io/ansible/ansible-runner   latest      40014730d1b7  18 hours ago        833 MB
quay.io/ansible/ansible-builder  latest      b0348faa7f41  8 weeks ago         779 MB

```

We can use ansible-navigator for executing the playbook in CLI using execution environments (Container image)

Go to power_aix_oracle collection and create ansible-navigator.yaml file

```
$ cat ansible-navigator.yaml
---
ansible-navigator:
   execution-environment:
      container-engine: podman
      enabled: True
      environment-variables:
         set:
            ANSIBLE_CONFIG: ansible.cfg
      image: oracle_aix_ee:latest


$ ansible-navigator run demo_play_aix_oracle.yml --pp=missing -m stdout
```

We can also execute playbook against execution environment from Ansible Controller (AAP2), steps were mentioned in Readme file

https://github.com/IBM/ansible-power-aix-oracle/tree/main/docs/README_ORA_SI_Play.pdf



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
    
a) Use "~/.ansible/collections/ansible_collections/ibm/power_aix/playbooks/demo_bootstrap.yml"
```
$ cat demo_bootstrap.yml
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

On AIX 7.3 use demo_bootstrap_dnf.yml from ibm.power_aix collection for configuring dnf and python. 
dnf and python will be available at /usr/opt/freeware/bin 

b)	Prepare ansible.cfg, inventory files for playbook execution. "p227n241" is AIX managed host  mentioned in inventory file. Update the "roles_path" to power-aix collection roles directory.

```
$ cat ansible.cfg
[defaults]
inventory = ./inventory
interpreter_python = /usr/bin/python
remote_user = root
host_key_checking = False
remote_tmp = /tmp/.ansible
roles_path = /home/ansible/.ansible/collections/ansible_collections/ibm/power_aix/roles
```

```
$ cat inventory
p227n241
```
c)	Executing bootstrap playbook
```
    $ ansible-playbook demo_bootstrap.yml
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

