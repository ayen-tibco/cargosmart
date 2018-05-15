export TIBCO_EP_HOME=/opt/tibco/sb-cep/10.2
mvn -s ./settings.xml -Pdocker clean package -Ddocker.showLogs
docker run -d -p 5000:5000 --restart=always --name registry registry:2
mvn -s ./settings.xml -Pdocker docker:push post-integration-test -DDOCKER_IMAGE_NAME=partition_docker\
 -Ddocker.skip.build=true -Ddocker.registry=localhost:5000 \ 
 -DskipNode2=true -DskipNode3=true -Ddocker.showLogs=true -Depmaven_hostname=localhost
