OpenGrok Tools Installations and Setup

Here we list tools and installation instructions for them. The tools are installed on a CentOS 6 server


Requirements

You need the following:

JDK 1.7 or higher
yum install java-1.7.0-openjdk
OpenGrok binaries
wget https://java.net/projects/opengrok/downloads/download/opengrok-0.12.1.2.tar.gz
A servlet container Tomact 7
wget http://apache.spd.co.il/tomcat/tomcat-7/v7.0.59/bin/apache-tomcat-7.0.59.tar.gz
2GB of memory of ram for indexing process using OpenGrok script (can use less, this is scaled for bigger deployments)
50GB of disk space

Installations

Step.1 - Installing the package

tar czf opengrok-0.12.1.2.tar.gz /opt/opengork  
mkdir src /opt/opengork 
Step.2 - Setting up the Sources. Having the web application container ready, and Deploy the web application.

crontab -e */30 * * * * /opt/opengrok/bin/runCloneOrUpdateDmsp.sh 2>&1 > /opt/opengrok/bin/runCloneOrUpdateDmsp.cron.log
and run the cron

 ./OpenGrok deploy 
If it fails to discover your container, please refer to optional steps on changing web application properties, which has manual steps on how to do this. Alternatively use

 OPENGROK_TOMCAT_BASE environment variable, e.g 
on

  # OPENGROK_TOMCAT_BASE=/path/to/my/tomcat/install ./OpenGrok deploy 
Step.4 - Populate DATA_ROOT Directory, let the indexer generate the project XML config file, update configuration.xml to your web app

Please change to opengrok directory (can vary on your system)

   cd /opt/opengrok/bin 
and run, if your SRC_ROOT is prepared under /var/opengrok/src

   ./OpenGrok index 
otherwise (if SRC_ROOT is in different directory) run:

   ./OpenGrok index <absolute_path_to_your_SRC_ROOT> 
Congratulations, you should now be able to point your browser to:

  http://YOUR_WEBAPP_SERVER:WEBAPPSRV_PORT/source  

Recommended links

For more information follow instruction in https://github.com/OpenGrok/OpenGrok/wiki/How-to-install-OpenGrok

