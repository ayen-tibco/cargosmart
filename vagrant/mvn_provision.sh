# mvn -s ../settings.xml initialize clean
mvn -s ../settings.xml -Pazure pre-integration-test -Dvagrant.skip.s3upload=true -Dvagrant.skip.plugins=true -DCONFIG_PROP_FILE=config.properties.mine
