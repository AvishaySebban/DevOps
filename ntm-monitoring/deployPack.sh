SCRIPT_PARAM=$1
SCRIPT_HOME=$(dirname $(readlink -f $0))
SRC_NAME=ntm-monitoring
SRC_ZIP_FILE="${SCRIPT_HOME}/tmp/${SRC_NAME}.zip"
ANSIBLE_YML_DEPLOYMENT="${SCRIPT_HOME}/ansible/ntm-monitoring.yml"
ANSIBLE_HOSTS="${SCRIPT_HOME}/ansible/ntm-hosts"
exitCode=0

# Go to workdir
pushd $SCRIPT_HOME

# prerequisite
##############
# Verify the SSH key
KEY_FILE=~/.ssh/AnsibleTestServers.pem
if [ ! -f ${KEY_FILE} ]
then
	echo -e "File is missing: KEY_FILE=${KEY_FILE}"
	exit 1
fi
# Create tmp folder
if [ ! -d tmp ]
then
	mkdir tmp
	echo "'tmp' folder was created"
fi

###### FUNCTIONS ######

callSshAgent()
{
		echo "Starting the ssh agent"
                eval `ssh-agent -s`
                echo "Started, SSH_AGENT_PID=${SSH_AGENT_PID} "
		ssh-add ${KEY_FILE}
		checkCode $?
		echo "Loaded, Git key [${KEY_FILE}}]"
}

killSshAgent()
{
        re='^[0-9]+$'
        if [ ! -z ${SSH_AGENT_PID} ] && [[ ${SSH_AGENT_PID} =~ $re ]]
        then
                kill -9 ${SSH_AGENT_PID}
                echo "INFO: SSH_AGENT_PID=${SSH_AGENT_PID} was killed"
        else
                echo "ERROR: SSH_AGENT_PID=${SSH_AGENT_PID}, and it is not a real PID"
                return 1
        fi
        return 0
}

checkCode()
{
	returnCode=$1
	[ $returnCode -gt 0 ] && exitFunc $returnCode
}

exitFunc()
{
	ERROR_CODE=$1
	killSshAgent
	# Return to executed dir
	popd
	exit $ERROR_CODE
}


##########################

######### MAIN ##########

# Load PEM for no password connection
callSshAgent $KEY_FILE

# Archaive package dir in tmp dir
echo "Creates ${SRC_ZIP_FILE} ..."
if [ -f ${SRC_ZIP_FILE} ]
then
	rm -f ${SRC_ZIP_FILE}
	echo "[${SRC_ZIP_FILE}] was deleted"
fi
zip -r -q ${SRC_ZIP_FILE} ${SRC_NAME}
checkCode $?

# Deploy package on remote servers
ansible-playbook -i  ${ANSIBLE_HOSTS} ${ANSIBLE_YML_DEPLOYMENT} -e APP_BASE_NAME=${SCRIPT_HOME} ${SCRIPT_PARAM} 
checkCode $?

exitFunc $exitCode

