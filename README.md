
*Copyright 2018 TIBCO, Inc. All rights reserved.*

# Intro
Design and create StreamBase query table application for deployment to Azure.

# Prerequisites
## Remote Slave Node
  * Minimum 4GB RAM/2 x vCPUs/20GB HDD, Recommend 8GB RAM/4 x vCPUs/50GB HDD
    SB Applications with multiple fragments requires at least 8GB/4vCPUs
  * Red Hat Enterprise/Centos Linux 7.3 with kernel 3.10.0.514.6.1
  
## Local Deployment Build Computer
  * StreamBase 10.2.1 Studio (env var set to TIBCO_EP_HOME=/opt/tibco/sb-cep/10.2)
  * Custom built StreamBase App Docker Image (ie. partition_docker)
  * curl, vagrant, ansible
  * Docker CE 17.10+
  
## Cloud Provisioning
  * Optional: Public Docker Registry for Azure Deployment
  * Azure credentials export to env var
      
# How to Build the App and Docker Image

## Build the SB App
Execute the following commands from the top level directory.
  
```sh
mvn -s ./settings.xml -Papp install
```

## Build and test the Docker Image:
Verify that your Docker engine is running first

```sh
sh -x ./docker_build.sh
```

Build all modules except for the partition\_docker_test and vagrant:

```sh
mvn -s ./settings.xml clean install 
```

# How to Deploy the App Natively and with Docker Swarm

## Deploy the StreamBase App Natively on Azure

1. Export your azure credentials

```
cd vagrant
source azure.env

export AZURE_SUBSCRIPTION_ID=your_SUBSCRIPTION_ID
export AZURE_CLIENT_ID=your_CLIENT_ID
export AZURE_SECRET=your_SECRET
export AZURE_TENANT_ID=your_TENANT_ID
```

2. Edit the variable DOCKERDEPLOY property in vagrant/src/main/resources/profiles/azure/config.properties.

```
DOCKERDEPLOY=false
```

3. Execute maven command below:

```sh
mvn -s ../settings.xml pre-integration-test
```

Results:

```
adams-mbp:vagrant adamyen$ mvn -s ../settings.xml -Pazure pre-integration-test -Dvagrant.skip.s3upload=true -Dvagrant.skip.plugins=true -DCONFIG_PROP_FILE=config.properties.mine
[INFO] Scanning for projects...
[INFO]                                                                         
[INFO] ------------------------------------------------------------------------
[INFO] Building Vagrant and Cloud Provisioning Examples 1.0.0-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO] 
[INFO] --- ep-maven-plugin:1.2.1:install-product (default-install-product-1) @ vagrant ---
[INFO] com.tibco.ep.sb.rt:platform_osxx86_64:zip:10.2.1:test already installed manually to /opt/tibco/sb-cep/10.2
[INFO] com.tibco.ep.sb.rt:platform_linuxx86_64:zip:10.2.1:provided already installed manually to /opt/tibco/sb-cep/10.2
[INFO] 
[INFO] --- ep-maven-plugin:1.2.1:set-resources (default-set-resources) @ vagrant ---
[INFO] 
[INFO] --- ep-maven-plugin:1.2.1:install-product (install_sb) @ vagrant ---
[INFO] com.tibco.ep.sb.rt:platform_osxx86_64:zip:10.2.1:test already installed manually to /opt/tibco/sb-cep/10.2
[INFO] com.tibco.ep.sb.rt:platform_linuxx86_64:zip:10.2.1:provided already installed manually to /opt/tibco/sb-cep/10.2
[INFO] 
[INFO] --- buildnumber-maven-plugin:1.4:create (initialize) @ vagrant ---
[INFO] Executing: /bin/sh -c cd '/Users/adamyen/git/oocl/vagrant' && 'git' 'rev-parse' '--verify' 'HEAD'
[INFO] Working directory: /Users/adamyen/git/oocl/vagrant
[INFO] Storing buildNumber: e57e09ae5f9dd7957c34eeebe3a07cc6689bdefe at timestamp: 1526068947761
[INFO] Storing buildScmBranch: master
[INFO] 
[INFO] --- properties-maven-plugin:1.0.0:read-project-properties (default) @ vagrant ---
[INFO] 
[INFO] --- maven-dependency-plugin:3.1.0:unpack-dependencies (unpack-tgz-files) @ vagrant ---
[INFO] 
[INFO] --- maven-resources-plugin:3.0.2:resources (default-resources) @ vagrant ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] Copying 50 resources
[INFO] 
[INFO] --- maven-compiler-plugin:3.6.1:compile (default-compile) @ vagrant ---
[INFO] No sources to compile
[INFO] 
[INFO] --- maven-dependency-plugin:3.1.0:copy (copy-sb-app) @ vagrant ---
[INFO] Configured Artifact: com.tibco.ep.sb.example:partitioning-application:1.0.0-SNAPSHOT:ep-application
[INFO] Configured Artifact: com.tibco.ep.sb.rt:platform_linuxx86_64:?:zip
[INFO] com.tibco.ep.sb.example:partitioning-application:1.0.0-SNAPSHOT:ep-application already exists in /Users/adamyen/git/oocl/vagrant/target/staging/azure/app
[INFO] com.tibco.ep.sb.rt:platform_linuxx86_64:10.2.1:zip already exists in /Users/adamyen/git/oocl/vagrant/target/staging/azure/app
[INFO] 
[INFO] --- maven-resources-plugin:3.0.2:copy-resources (copy-vagrantfile) @ vagrant ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] Copying 6 resources
[INFO] Copying 5 resources
[INFO] 
[INFO] --- maven-resources-plugin:3.0.2:copy-resources (copy-provisioner-scripts) @ vagrant ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] Copying 100 resources
[INFO] 
[INFO] --- maven-resources-plugin:3.0.2:copy-resources (copy-cloud-inventory-script) @ vagrant ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory /Users/adamyen/git/oocl/vagrant/./src/main/azure
[INFO] 
[INFO] --- maven-resources-plugin:3.0.2:copy-resources (copy-localhost-inventory) @ vagrant ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] Copying 1 resource
[INFO] 
[INFO] --- maven-resources-plugin:3.0.2:copy-resources (copy-nodeconfig) @ vagrant ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] Copying 1 resource
[INFO] 
[INFO] --- maven-antrun-plugin:1.8:run (install-hostmanager-plugin) @ vagrant ---
[INFO] Executing tasks

install_hostmanager_plugin:
[INFO] Executed tasks
[INFO] 
[INFO] --- maven-antrun-plugin:1.8:run (get-azure-inventory-script) @ vagrant ---
[INFO] Executing tasks

get-azure-inventory-script:
     [exec]   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
     [exec]                                  Dload  Upload   Total   Spent    Left  Speed
     [exec] 
     [exec]   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0100   151  100   151    0     0    169      0 --:--:-- --:--:-- --:--:--   169
     [exec]   0     0    0     0    0     0      0      0 --:--:--  0:00:01 --:--:--     0100 38050  100 38050    0     0  32018      0  0:00:01  0:00:01 --:--:--  222k
[INFO] Executed tasks
[INFO] 
[INFO] --- maven-antrun-plugin:1.8:run (upload-sb-s3) @ vagrant ---
[INFO] Executing tasks

upload_sb_s3:
[INFO] Executed tasks
[INFO] 
[INFO] --- maven-antrun-plugin:1.8:run (install-azure-plugin) @ vagrant ---
[INFO] Executing tasks

install_azure_plugin:
[INFO] Executed tasks
[INFO] 
[INFO] --- maven-antrun-plugin:1.8:run (create-azure-vms) @ vagrant ---
[INFO] Executing tasks

create_azure_vms:
     [exec] ERROR loader: Unknown config sources: ["2168859060_machine_oocl-1", :"2152467560_azure.box_azure"]
     [exec] ERROR loader: Unknown config sources: ["2168859060_machine_oocl-1", :"2152467560_azure.box_azure"]
     [exec] ERROR loader: Unknown config sources: ["2168859060_machine_oocl-1"]
     [exec] ERROR loader: Unknown config sources: ["2168859060_machine_oocl-1", :"2152467560_azure.box_azure", "2168859060_machine_oocl-2"]
     [exec] ERROR loader: Unknown config sources: ["2168859060_machine_oocl-1", :"2152467560_azure.box_azure", "2168859060_machine_oocl-2"]
     [exec] ERROR loader: Unknown config sources: ["2168859060_machine_oocl-1", "2168859060_machine_oocl-2"]
     [exec] Bringing machine 'oocl-1' up with 'azure' provider...
     [exec] Bringing machine 'oocl-2' up with 'azure' provider...
     [exec] Bringing machine 'oocl-3' up with 'azure' provider...
     [exec] ==> oocl-1: The machine is already created.
     [exec] ==> oocl-2: Launching an instance with the following settings...
     [exec] ==> oocl-2:  -- Management Endpoint: https://management.azure.com
     [exec] ==> oocl-2:  -- Subscription Id: 59fd09c2-9932-4975-8042-f048c202ba62
     [exec] ==> oocl-2:  -- Resource Group Name: oocl
     [exec] ==> oocl-2:  -- Location: eastus
     [exec] ==> oocl-2:  -- SSH User Name: vagrant
     [exec] ==> oocl-2:  -- Admin Username: vagrant
     [exec] ==> oocl-2:  -- VM Name: oocl-2
     [exec] ==> oocl-2:  -- VM Storage Account Type: Premium_LRS
     [exec] ==> oocl-2:  -- VM Size: Standard_DS2_v2
     [exec] ==> oocl-2:  -- Image URN: OpenLogic:CentOS:7.4:latest
     [exec] ==> oocl-2:  -- Virtual Network Name: oocl_vn
     [exec] ==> oocl-2:  -- Subnet Name: oocl_subnet
     [exec] ==> oocl-2:  -- TCP Endpoints: ["5556-5558", "10000"]
     [exec] ==> oocl-2:  -- DNS Label Prefix: oocl-2
     [exec] ==> oocl-2:  -- Create or Update of Resource Group: oocl
     [exec] ==> oocl-2:  -- Starting deployment
     [exec] ==> oocl-2:  -- Finished deploying
     [exec] ==> oocl-2: Waiting for SSH to become available...
     [exec] ==> oocl-2: Machine is booted and ready for use!
     [exec] ==> oocl-2: Running provisioner: shell...
     [exec]     oocl-2: Running: inline script
     [exec]     oocl-2: Retrieving http://mirror.centos.org/centos/7/extras/x86_64/Packages/epel-release-7-9.noarch.rpm
     [exec]     oocl-2: Preparing...                          
     [exec]     oocl-2: ########################################
     [exec]     oocl-2: Updating / installing...
     [exec]     oocl-2: epel-release-7-9                      
     [exec]     oocl-2: ###
     [exec]     oocl-2: ##
     [exec]     oocl-2: #
     [exec]     oocl-2: #####
     [exec]     oocl-2: #############################
     [exec]     oocl-2: Loaded plugins: fastestmirror, langpacks
     [exec]     oocl-2: Cleaning repos: base epel extras openlogic updates
     [exec]     oocl-2: 0 metadata files removed
     [exec]     oocl-2: 0 sqlite files removed
     [exec]     oocl-2: 0 metadata files removed
     [exec]     oocl-2: Loaded plugins: fastestmirror, langpacks
     [exec]     oocl-2: http://csc.mcs.sdsmt.edu/epel/7/x86_64/repodata/repomd.xml: [Errno 12] Timeout on http://csc.mcs.sdsmt.edu/epel/7/x86_64/repodata/repomd.xml: (28, 'Connection timed out after 30001 milliseconds')
     [exec]     oocl-2: Trying other mirror.
     [exec]     oocl-2: Determining fastest mirrors
     [exec]     oocl-2:  * epel: mirror.math.princeton.edu
     [exec]     oocl-2: Metadata Cache Created
     [exec] ==> oocl-2: Running provisioner: shell...
     [exec]     oocl-2: Running: inline script
     [exec]     oocl-2: Retrieving http://mirror.centos.org/centos/7/extras/x86_64/Packages/epel-release-7-9.noarch.rpm
     [exec]     oocl-2: Preparing...                          ########################################
     [exec]     oocl-2: 	package epel-release-7-9.noarch is already installed
     [exec]     oocl-2: Loaded plugins: fastestmirror, langpacks
     [exec]     oocl-2: Cleaning repos: base epel extras openlogic updates
     [exec]     oocl-2: 17 metadata files removed
     [exec]     oocl-2: 10 sqlite files removed
     [exec]     oocl-2: 0 metadata files removed
     [exec]     oocl-2: Loaded plugins: fastestmirror, langpacks
     [exec]     oocl-2: Loading mirror speeds from cached hostfile
     [exec]     oocl-2:  * epel: mirror.math.princeton.edu
     [exec]     oocl-2: Metadata Cache Created
     [exec] ==> oocl-3: Launching an instance with the following settings...
     [exec] ==> oocl-3:  -- Management Endpoint: https://management.azure.com
     [exec] ==> oocl-3:  -- Subscription Id: 59fd09c2-9932-4975-8042-f048c202ba62
     [exec] ==> oocl-3:  -- Resource Group Name: oocl
     [exec] ==> oocl-3:  -- Location: eastus
     [exec] ==> oocl-3:  -- SSH User Name: vagrant
     [exec] ==> oocl-3:  -- Admin Username: vagrant
     [exec] ==> oocl-3:  -- VM Name: oocl-3
     [exec] ==> oocl-3:  -- VM Storage Account Type: Premium_LRS
     [exec] ==> oocl-3:  -- VM Size: Standard_DS2_v2
     [exec] ==> oocl-3:  -- Image URN: OpenLogic:CentOS:7.4:latest
     [exec] ==> oocl-3:  -- Virtual Network Name: oocl_vn
     [exec] ==> oocl-3:  -- Subnet Name: oocl_subnet
     [exec] ==> oocl-3:  -- TCP Endpoints: ["5556-5558", "10000"]
     [exec] ==> oocl-3:  -- DNS Label Prefix: oocl-3
     [exec] ==> oocl-3:  -- Create or Update of Resource Group: oocl
     [exec] ==> oocl-3:  -- Starting deployment
     [exec] ==> oocl-3:  -- Finished deploying
     [exec] ==> oocl-3: Waiting for SSH to become available...
     [exec] ==> oocl-3: Machine is booted and ready for use!
     [exec] ==> oocl-3: Running provisioner: shell...
     [exec]     oocl-3: Running: inline script
     [exec]     oocl-3: Retrieving http://mirror.centos.org/centos/7/extras/x86_64/Packages/epel-release-7-9.noarch.rpm
     [exec]     oocl-3: Preparing...                          
     [exec]     oocl-3: ########################################
     [exec]     oocl-3: Updating / installing...
     [exec]     oocl-3: epel-release-7-9                      
     [exec]     oocl-3: ###
     [exec]     oocl-3: ##
     [exec]     oocl-3: #
     [exec]     oocl-3: #####
     [exec]     oocl-3: #############################
     [exec]     oocl-3: Loaded plugins: fastestmirror, langpacks
     [exec]     oocl-3: Cleaning repos: base epel extras openlogic updates
     [exec]     oocl-3: 0 metadata files removed
     [exec]     oocl-3: 0 sqlite files removed
     [exec]     oocl-3: 0 metadata files removed
     [exec]     oocl-3: Loaded plugins: fastestmirror, langpacks
     [exec]     oocl-3: http://csc.mcs.sdsmt.edu/epel/7/x86_64/repodata/repomd.xml: [Errno 12] Timeout on http://csc.mcs.sdsmt.edu/epel/7/x86_64/repodata/repomd.xml: (28, 'Connection timed out after 30001 milliseconds')
     [exec]     oocl-3: Trying other mirror.
     [exec]     oocl-3: Determining fastest mirrors
     [exec]     oocl-3:  * epel: ewr.edge.kernel.org
     [exec]     oocl-3: Metadata Cache Created
     [exec] ==> oocl-3: Running provisioner: shell...
     [exec]     oocl-3: Running: inline script
     [exec]     oocl-3: Retrieving http://mirror.centos.org/centos/7/extras/x86_64/Packages/epel-release-7-9.noarch.rpm
     [exec]     oocl-3: Preparing...                          
     [exec]     oocl-3: ########################################
     [exec]     oocl-3: 	package epel-release-7-9.noarch is already installed
     [exec]     oocl-3: Loaded plugins: fastestmirror, langpacks
     [exec]     oocl-3: Cleaning repos: base epel extras openlogic updates
     [exec]     oocl-3: 17 metadata files removed
     [exec]     oocl-3: 10 sqlite files removed
     [exec]     oocl-3: 0 metadata files removed
     [exec]     oocl-3: Loaded plugins: fastestmirror, langpacks
     [exec]     oocl-3: Loading mirror speeds from cached hostfile
     [exec]     oocl-3:  * epel: ewr.edge.kernel.org
     [exec]     oocl-3: Metadata Cache Created
     [exec] ==> oocl-3: Running provisioner: shell...
     [exec]     oocl-3: Running: inline script
     [exec]     oocl-3: Retrieving http://mirror.centos.org/centos/7/extras/x86_64/Packages/epel-release-7-9.noarch.rpm
     [exec]     oocl-3: Preparing...                          
     [exec]     oocl-3: ########################################
     [exec]     oocl-3: 	package epel-release-7-9.noarch is already installed
     [exec]     oocl-3: Loaded plugins: fastestmirror, langpacks
     [exec]     oocl-3: Cleaning repos: base epel extras openlogic updates
     [exec]     oocl-3: 17 metadata files removed
     [exec]     oocl-3: 10 sqlite files removed
     [exec]     oocl-3: 0 metadata files removed
     [exec]     oocl-3: Loaded plugins: fastestmirror, langpacks
     [exec]     oocl-3: Loading mirror speeds from cached hostfile
     [exec]     oocl-3:  * epel: ewr.edge.kernel.org
     [exec]     oocl-3: 
```