#!/bin/bash
# Utility functions

# IPs
export BUILD_SERVER_IP=10.35.25.5
export NTP_SERVER=10.35.25.81
export XEN=10.35.25.100
export MERCURIAL_IP=10.35.25.27
export NEXUS_IP=10.35.25.26
export NETAPP_IP=10.35.20.200
export SONAR_IP=10.35.25.40
export E2E_TRD_IP=10.35.25.127
export E2E_DMSD_IP=10.35.25.128

# URLs
export MAIN_JENKINS_URL=http://$BUILD_SERVER_IP/jenkins-dmsp
export NEXUS_BASE_URL=http://$NEXUS_IP/nexus
export HG_BASE=http://$MERCURIAL_IP/mercurial
export SONAR_URL=http://$SONAR_IP:9000/sonar

# Files and paths
export TOOLS=/opt/buildtools
export DMSP_COMPONENTS=/opt/dmsp-components
export SIBERIA_COMPONENTS=/opt/siberia-components
export HG_FS_ROOT=/mercurial
export HG_SERVER_FS_ROOT=/srv/mercurial
export DMSP_RELEASE_DIR=/releases/DMSP/Components/1_ReadyForTesting
export NEW_DMSP_RELEASE_DIR=/releases/DMSP/Releases
export SIBERIA_RELEASE_DIR=/releases/Siberia/Releases
export JENKINS_USER_CONTENT=$JENKINS_HOME/userContent
export DEV_VERSIONS_FILE=$JENKINS_USER_CONTENT/dev.versions
export DB_NAMES_FILE=$JENKINS_USER_CONTENT/db.names.properties
export FAIL_BUILD_FLAG=$WORKSPACE/../FAIL_BUILD
export NO_CHANGES_LOCK=$WORKSPACE/../${JOB_NAME}.NO_CHANGES_FROM_LAST_BUILD
export DMSP_SERVER_FILE=$WORKSPACE/../${JOB_NAME}.DMSP_SERVER
export PRIVATE_E2E_FILE=$JENKINS_HOME/userContent/private.e2e.properties
export PRIVATE_E2E_HTML=$JENKINS_HOME/userContent/private.e2e.html
export CHANGE_LOG_REPOSITORY=${DMSP_COMPONENTS}-change-logs-repository
export DEPENDENCY_TREES_DIRECORY=${DMSP_COMPONENTS}-dependency-trees
export POMS_DIRECORY=${DMSP_COMPONENTS}-poms

# RPMs and ZIPs
export MERCURIAL_RPM=$NEXUS_BASE_URL/content/repositories/thirdparty/com/selenic/mercurial/mercurial/2.2.2-1.el6.rfx.x86_64/mercurial-2.2.2-1.el6.rfx.x86_64.rpm
export HTOP_RPM=$NEXUS_BASE_URL/content/repositories/thirdparty/hm/hisham/htop/1.0.2-1.el6.rf.x86_64/htop-1.0.2-1.el6.rf.x86_64.rpm
export ANT_ZIP=$NEXUS_BASE_URL/content/repositories/thirdparty/org/apache/ant/apache-ant/1.8.4/apache-ant-1.8.4.zip
export MAVEN_ZIP=$NEXUS_BASE_URL/content/repositories/thirdparty/org/apache/maven/apache-maven/3.0.4/apache-maven-3.0.4.zip
export RPM_BUILD_RPM=$NEXUS_BASE_URL/content/repositories/thirdparty/org/rpm/rpm-build/4.8.0-32.el6.x86_64/rpm-build-4.8.0-32.el6.x86_64.rpm

# Common strings
export RELEASES_MOUNT=$NETAPP_IP:/vol/releases/releases
export SSH_OPTS="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet"
export JENKINS_DB=jenkinsDB
export JENKINS_DB_CMD="mysql -u$JENKINS_DB -D$JENKINS_DB -h$BUILD_SERVER_IP"

# Logging function
logger()
{
	DATE_TIME=`date +"%Y-%m-%d %H:%M:%S"`
	if [ -z "$CONTEXT" ]
	then
		CONTEXT=`caller`
	fi
	MESSAGE=$1
	CONTEXT_LINE=`echo $CONTEXT | awk '{print $1}'`
	CONTEXT_FILE=`echo $CONTEXT | awk -F"/" '{print $NF}'`
	printf "%s %05s %s %s\n" "$DATE_TIME" "[$CONTEXT_LINE" "$CONTEXT_FILE]" "$MESSAGE"
	CONTEXT=
}

# Abort with error message and exit 1
abort()
{
	if [ -z "$CONTEXT" ]
	then
		CONTEXT=`caller`
	fi
	logger "ERROR: $1"
	echo
	exit 1
}

# Display usage message and abort
usageAndExit()
{
	CONTEXT=`caller`
	abort "Usage: $1"
}

# Is this the main build server?
isMainBuildServer()
{
	MY_IP=`hostname -i`
	if [ "$MY_IP" == "$BUILD_SERVER_IP" ]
	then
		echo -n "true"
	else
		echo -n "false"
	fi
}

# Accept a version string and increment its last element (assume string is passed correctly)
incrementVersionLastElement()
{
	IN=$1

	VER1=`echo $IN | awk -F\. 'BEGIN{i=2}{res=$1; while(i<NF){res=res"."$i; i++}print res}'`
	VER2=`echo $IN | awk -F\. '{print $NF}'`

	VER2=`expr $VER2 + 1`

	OUT="$VER1.$VER2"

	echo $OUT
}

# Accept a version string and element number
# Increment selected element and reset all following elements to 0
incrementVersionCustomElement()
{
	local VERSION_TO_CHANGE=$1
	local ELEMENT=$2
	local UPDATED_VERSION=

	# Replace period with spaces for the for loop
	VERSION_TO_CHANGE=`echo -n $VERSION_TO_CHANGE | tr '.' ' '`

	local I=1
	DONE=false

	for E in $VERSION_TO_CHANGE
	do
		# Check if reached the element to change
		if [ "$DONE" != "true" ] && [ $I -eq $ELEMENT ]
		then
			let E=$E+1
			DONE=true
		fi

		# Check if need to reset rest of elements to 0
		if [ "$DONE" == "true" ] && [ $I -ne $ELEMENT ]
		then
			E=0
		fi

		UPDATED_VERSION="${UPDATED_VERSION}.$E"
		let I=$I+1
	done

	echo -n $UPDATED_VERSION | sed 's/^.//g'
}

# Verify that the parameter passed is an IP Address:
function isValidIp()
{
	if [ `echo $1 | grep -o '\.' | wc -l` -ne 3 ]
	then
		logger "'$1' does not look like an IP Address (does not contain 3 dots)."
		return 1
	elif [ `echo $1 | tr '.' ' ' | wc -w` -ne 4 ]
	then
		logger "'$1' does not look like an IP Address (does not contain 4 octets)."
		return 1
	else
		for OCTET in `echo $1 | tr '.' ' '`
		do
			if ! [[ $OCTET =~ ^[0-9]+$ ]]
			then
				logger "'$1' does not look like in IP Address (octet '$OCTET' is not numeric)."
				return 1
			elif [[ $OCTET -lt 0 || $OCTET -gt 255 ]]
			then
				logger "'$1' does not look like in IP Address (octet '$OCTET' in not in range 0-255)."
				return 1
			fi
		done
	fi

	return 0;
}

# Get a property value from a pom.xml
getPropertyValueFromPomXml()
{
	# Check arguments
	if [ $# -lt 2 ]
	then
		usageAndExit "getPropertyValueFromPomXml <pom.xml> <property to get>"
	fi

	# Verify pom.xml exists
	if [ ! -f "$1" ]
	then
		abort "ERROR: $1 does not exist"
	fi

	# Get the property value
	VALUE=`cat $1 | sed '/<!--.*-->/d'| sed '/<!--/,/-->/d' | sed -ne '/<properties>/,/<\/properties>/p' | sed -ne "s/.*<$2>\(.*\)<\/$2>/\1/p" | tr '\n' ',' | sed 's/,$//g'`

	echo -n $VALUE
}

# Get the version for an artifact from on its pom
getGAVValueFromPomXml()
{
	# Check arguments
	if [ $# -lt 2 ]
	then
		usageAndExit "getGAVValueFromPomXml <pom.xml> <groupId/artifactId/version>"
	fi
	if [ ! -f $1 ]
	then
		usageAndExit "getGAVValueFromPomXml <pom.xml> <groupId/artifactId/version>"
	fi
	if [[ ! $2 =~ (groupId|artifactId|version) ]]
	then
		usageAndExit "getGAVValueFromPomXml <pom.xml> <parameter (groupId/artifactId/version)>"
	fi

	VALUE=`echo -e "setns x=http://maven.apache.org/POM/4.0.0\ncat /x:project/x:$2/text()" | xmllint --shell $1 | grep -v /`

	if [ -z "$VALUE" ]
	then
		abort "Failed getting $2 for $1"
	fi

	echo -n $VALUE
}

# Get the version for an artifact from on its pom
getVersionForArtifactFromPomXml()
{
	# Check arguments
	if [ ! -f $1 ]
	then
		usageAndExit "getVersionForArtifactFromPomXml <pom.xml>"
	fi

	VERSION=`echo -e 'setns x=http://maven.apache.org/POM/4.0.0\ncat /x:project/x:version/text()' | xmllint --shell $1 | grep -v /`

	if [ -z "$VERSION" ]
	then
		abort "Failed getting version for $1"
	fi

	echo -n $VERSION
}

# Get parent parameter from pom.xml
getParentParameterFromPomXml()
{
	# Check arguments
	if [ $# -lt 2 ]
	then
		usageAndExit "getParentParameterFromPomXml <pom.xml> <parameter (groupId|artifactId|version)>"
	fi

	PARAM_VALUE=`echo -e "setns x=http://maven.apache.org/POM/4.0.0\ncat /x:project/x:parent/x:$2/text()" | xmllint --shell $1 | grep -v /`

	echo -n $PARAM_VALUE
}

# Get the latest version for an artifact based on its pom
getLatestVersionForArtifactFromPomXml()
{
	# Check arguments
	if [ ! -f $1 ]
	then
		usageAndExit "getLatestVersionForArtifactFromPomXml <pom.xml>"
	fi

	GROUP_ID=`echo -e 'setns x=http://maven.apache.org/POM/4.0.0\ncat /x:project/x:groupId/text()' | xmllint --shell $1 | grep -v /`
	if [ -z "$GROUP_ID" ]
	then
		GROUP_ID=`echo -e 'setns x=http://maven.apache.org/POM/4.0.0\ncat /x:project/x:parent/x:groupId/text()' | xmllint --shell $1 | grep -v /`
	fi
	ARTIFACT_ID=`echo -e 'setns x=http://maven.apache.org/POM/4.0.0\ncat /x:project/x:artifactId/text()' | xmllint --shell $1 | grep -v /`

	if [ -z "$GROUP_ID" ] || [ -z "$ARTIFACT_ID" ]
	then
		abort "Failed getting groupId or artifactId for $1"
	fi

	LAST_VERSION=`curl --silent "$NEXUS_BASE_URL/service/local/artifact/maven/resolve?r=releases&g=$GROUP_ID&a=$ARTIFACT_ID&v=RELEASE&e=pom" | grep "<version>" | sed "s|<version>\(.*\)</version>|\1|g" | sed 's| ||g'`

	echo -n $LAST_VERSION
}

# Get the list of dmsp version properties from a pom.xml
getDmspVersionPropertiesFromPomXml()
{
	# Check arguments
	if [ $# -lt 1 ]
	then
		usageAndExit "getDmspVersionPropertiesFromPomXml <pom.xml>"
	fi

	# Verify pom.xml exists
	if [ ! -f "$1" ]
	then
		abort "ERROR: $1 does not exist"
	fi

	TYPE='[0-9]'
	if [ ! -z "$TYPE_OVERRIDE" ]
	then
		TYPE=$TYPE_OVERRIDE
	fi

	# Get the list of all dmsp-xxx.version properties as a comma delimited list
	VALUE=`cat $1 | sed '/<!--.*-->/d'| sed '/<!--/,/-->/d' | sed -ne '/<properties>/,/<\/properties>/p' | sed -ne "s/.*<\(dmsp.*\)>$TYPE.*/\1/p" | tr '\n' ',' | sed 's/,$//g'`

	echo -n $VALUE
}

# Get a dynamic server from XEN
# Exports the variable DMSP_SERVER with the server IP
getDmspServer()
{
	logger "RUN STEP: Get DMSP server from XEN"
	logger "------------------------- Get server from XEN -------------------"
	RESULT=0
	if [ -z "$COMPONENT" ]; then abort "COMPONENT is not set"; fi

	DESCRIPTION="$COMPONENT tests"
	if [ "$DEVELOPMENT_VM" == "true" ]
	then
		DESCRIPTION=$COMPONENT
	fi

	DMSP_SERVER=`$TOOLS/XEN/getDmspInstance.sh "$DESCRIPTION"`
	if [ "$?" != "0" ]
	then
		logger "ERROR: Failed getting a VM"
		logger "ERROR returned is: $DMSP_SERVER"
		RESULT=1
	else
		logger "Got new server $DMSP_SERVER"
		export DMSP_SERVER
		echo -n $DMSP_SERVER> acceptance.server
		cp acceptance.server $DMSP_SERVER_FILE
	fi

	logger "-----------------------------------------------------------------"
	return $RESULT
}

# Delete a server from XEN
# Gets a list of space delimited IPs to delete
deleteDmspServer()
{
	logger "------------------------- Delete server from XEN ----------------"
	VM_TO_DELETE=$1
	MY_IP=`hostname -i`

	if [ -z "$VM_TO_DELETE" ]
	then
		logger "IP not passed. Trying to get it from DB"
		logger "JOB_NAME is $JOB_NAME"

		VM_TO_DELETE=`jenkinsDb "SELECT ip FROM vm WHERE parent_ip='$MY_IP' AND job_name='$JOB_NAME';" | tr '\n' ' '`

		# In case not in DB but on local file (should be removed once all environments use the new code)
		if [ -z "$VM_TO_DELETE" ]
		then
			logger "IP not found in DB. Trying to get it from local files"
			if [ -f acceptance.server ]
			then
				VM_TO_DELETE=`cat acceptance.server`
				logger "File acceptance.server has $VM_TO_DELETE"
			fi

			if [ -f $DMSP_SERVER_FILE ]
			then
				VM_TO_DELETE=`cat $DMSP_SERVER_FILE`
				logger "File $DMSP_SERVER_FILE has $VM_TO_DELETE"
			fi
		else
			logger "IP from DB is $VM_TO_DELETE"
		fi

		logger "Removing IP files if exist"
		if [ -f acceptance.server ]; then rm -fv acceptance.server; fi
		if [ -f $DMSP_SERVER_FILE ]; then rm -fv $DMSP_SERVER_FILE; fi
	fi

	if [ -z "$VM_TO_DELETE" ] || [ "$VM_TO_DELETE" == "na" ] || [[ "$VM_TO_DELETE" =~ "Removed" ]]
	then
		logger "WARNING: Unable to get IP of VM to delete"
		return 0
	fi

	logger "VM_TO_DELETE is $VM_TO_DELETE"
	logger "Validating IP(s)"
	for SINGLE_IP in $VM_TO_DELETE
	do
		logger "Checking if $SINGLE_IP is a valid IP"
		isValidIp $SINGLE_IP
		if [ $? -ne 0 ]
		then
			logger "ERROR: $SINGLE_IP is not a valid IP"
			return 1
		fi
		logger "$SINGLE_IP is a valid IP"
	done

	$TOOLS/XEN/deleteInstance.sh "$VM_TO_DELETE"
	if [ $? -ne 0 ]
	then
		logger "WARNING: Failed deleting VM $VM_TO_DELETE"
		mkdir -p $JENKINS_HOME/logs/XEN
		DATE_TIME=`date +"%Y-%m-%d %H:%M:%S"`
		echo "$DATE_TIME: $JOB_NAME failed deleting VM $VM_TO_DELETE<br>" >> $JENKINS_HOME/logs/XEN/delete.err.log
	else
		logger "VM $VM_TO_DELETE removed. Updating acceptance.server"
		echo "Removed" > acceptance.server
	fi

	logger "-----------------------------------------------------------------"
}

# Get an artifact from Nexus based on GAV parameters
getArtifactFromNexus()
{
	GET_REPOSITORY=$1
	GET_GROUP_ID=$2
	GET_ARTIFACT_ID=$3
	GET_VERSION=$4

	if [ -z "$GET_REPOSITORY" ]
	then
		abort "GET_REPOSITORY must be set"
	fi
	if [ -z "$GET_GROUP_ID" ]
	then
		abort "GET_GROUP_ID must be set"
	fi
	if [ -z "$GET_ARTIFACT_ID" ]
	then
		abort "GET_ARTIFACT_ID must be set"
	fi

	# If no version provided, get the latest
	if [ -z "$GET_VERSION" ]
	then
		GET_VERSION=`curl --silent "$NEXUS_BASE_URL/service/local/artifact/maven/resolve?r=$GET_REPOSITORY&g=$GET_GROUP_ID&a=$GET_ARTIFACT_ID&v=RELEASE&e=pom" | grep "<version>" | sed "s|<version>\(.*\)</version>|\1|g" | sed 's| ||g'`

		# If still no version found, abort
		if [ -z "$GET_VERSION" ]
		then
			abort "No version found in Nexus"
		fi
	fi

	logger "Getting artifact $GET_GROUP_ID:$GET_ARTIFACT_ID:$GET_VERSION from Nexus"

	wget -nv "$NEXUS_BASE_URL/service/local/artifact/maven/redirect?r=$GET_REPOSITORY&g=$GET_GROUP_ID&a=$GET_ARTIFACT_ID&v=$GET_VERSION"
	if [ "$?" != "0" ]
	then
		abort "Failed getting artifact"
	fi
}

# Check if a directory is empty or not
isDirEmpty()
{
	if [ -z "$1" ]
	then
		abort "Must pass directory to check"
	fi

	if [ ! -d $1 ]
	then
		echo -n "true"
	else
		if [ `ls -a $1/ | wc -w` -gt 2 ]
		then
			echo -n "false"
		else
			echo -n "true"
		fi
	fi

	return 0
}

# Wait for ssh access to server up to a given timeout
waitForSshToServer()
{
	if [ -z "$1" ]
	then
		abort "Usage: waitForSshToServer <server ip> [optional timeout]"
	fi

	SERVER_TO_CHECK=$1
	TIMEOUT=120

	if [ ! -z "$2" ]
	then
		TIMEOUT=$2
	fi

	logger "Going to wait for SSH access to $SERVER_TO_CHECK up to $TIMEOUT seconds"

	COUNT=1
	SSH_AVAILABLE=1

	# Waiting for ssh to be available or TIMEOUT to exceed
	while [ "$SSH_AVAILABLE" != "0" ] && [ "$COUNT" -lt $TIMEOUT ]
	do
		sleep 1
		ssh -tt $SSH_OPTS $SERVER_TO_CHECK exit
		SSH_AVAILABLE=$?
		let COUNT=COUNT+1
	done

	if [ "$SSH_AVAILABLE" == "0" ]
	then
		logger "Server is up! Wait time was $COUNT seconds"
	else
		abort "$SERVER_TO_CHECK failed to start in a reasonable time"
	fi

}

# Create a fail build flag
failBuild()
{
	logger "Creating a fail build flag $FAIL_BUILD_FLAG"
	touch $FAIL_BUILD_FLAG
}

# Run Jenkins DB SQL commands
jenkinsDb()
{
	if [ -z "$1" ]
	then
		usageAndExit "`basename $0` <SQL command>"
	fi

	# Show SQL
#	logger "SQL passed is: $1"

	# If the command is a select, remove the headers and table decorations to get a clean output
	SQL_DISPLAY_OPTS=
	if [[ "$1" =~ ^(SEL|sel) ]]
	then
		SQL_DISPLAY_OPTS="-N -B"
	fi

	# Set the password
	CURRENT_MYSQL_PWD=$MYSQL_PWD
	export MYSQL_PWD=$JENKINS_DB

	# Running command
	$JENKINS_DB_CMD $SQL_DISPLAY_OPTS -e "$1"
	RESULT=$?

	# Set the password back to its original (if was set)
	export MYSQL_PWD=$CURRENT_MYSQL_PWD

	return $RESULT
}

# Print a given file with the file name as a prefix in each line
dumpFile()
{
	echo;echo
	cat $1 | sed -e "s|^|[$1] |g"
	echo;echo
}
