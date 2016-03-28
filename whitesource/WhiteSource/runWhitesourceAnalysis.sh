#!/bin/bash

#RepoList.txt

TOOLS=/opt/buildtools
REPO_LIST=/opt/buildtools/stash/RepoList.txt

. $TOOLS/utils.sh

ERR_LOG=$ROOT_WORKSPACE/errors.log

# Pull repository list from Git server (defaults to DMSP)
if [ -z "$FOSS_PRODUCT" ]
then
	logger "FOSS_PRODUCT is not set. Setting it to dmsp"
	FOSS_PRODUCT=dmsp
fi


ROOT_WORKSPACE=`pwd`
REPO_LIST_FILE=${ROOT_WORKSPACE}/${FOSS_PRODUCT}.repository.list
mkdir -p ${ROOT_WORKSPACE}/${FOSS_PRODUCT}
REPO_BASE_DIR=${ROOT_WORKSPACE}/${FOSS_PRODUCT}

# Clean repo list
if [ -f $REPO_LIST_FILE ] 
then
	rm -f $REPO_LIST_FILE
fi

#Check if RepoList.txt exist
if [ ! -z $1 ]
then
	REPO_LIST=$1
else
	REPO_LIST='ALL'
fi

abort()
{
        logger "ERROR: $1" | tee -a $ERR_LOG
        echo
        exit 1
}
        echo
        logger "Getting Git repositories for $REPO_LIST"

#Check if we want to use the repo_list 
if [ $REPO_LIST == 'ALL' ] 
then
	LIST_OF_REPO=$(python $TOOLS/stash/getGitRepos.py)
else
	LIST_OF_REPO=`cat $REPO_LIST`
fi	
	
        IFS=$'\n' #IFS (Internal Field Separator) variable so that it splits fields by something other than the default whitespace

        for LINE in $LIST_OF_REPO
        do
                REPO_NAME=$(echo $LINE | awk -F'/' '{print $NF}' | sed 's/.git$//g')
				echo $REPO_NAME >> $REPO_LIST_FILE
                REPO_URL=$(echo $LINE | awk -F= '{print $2}')

                logger "Processing $FOSS_PRODUCT - Name: $REPO_NAME, Clone URL: $REPO_URL"
                REPO_NAME=$(echo -n $REPO_NAME | tr '[A-Z]' '[a-z]')
                logger "Checking if $REPO_NAME exists"

		REPO_DIR=${REPO_BASE_DIR}/${REPO_NAME}
                if [ -d $REPO_DIR ]
                then
                        logger "$REPO_NAME exists in [$REPO_DIR] folder. Updating it"
                        pushd $REPO_DIR
                        git pull origin master
                        if [ $? -ne 0 ]; then logger "WARNING: Failed updating $REPO_NAME"; fi
                        popd
                else
                        logger "Cloning $REPO_NAME to [${REPO_BASE_DIR}] folder."
			pushd ${REPO_BASE_DIR}
                        git clone $REPO_URL
                        if [ $? -ne 0 ]; then abort "Failed cloning $REPO_URL, Project Name: $PROJECT_NAME" ; fi
			popd
                fi

        done
        IFS=

	echo


						
logger "Running the whitesource analysis"

# For each repo, run the whitesource analysis
for REPO in `ls ${REPO_BASE_DIR}`
do
	echo
	REPO_DIR=${REPO_BASE_DIR}/${REPO_NAME}
	if [ -d ${REPO_DIR} ]
	then

		# Check if repository is still in the repositories list (will remove if not)
		grep $REPO $REPO_LIST_FILE > /dev/null
		if [ $? -ne 0 ]
		then
			logger "$REPO is not in the repository list. Removing it [${REPO_DIR}]"
			rm -rf ${REPO_DIR}
		else

			logger "Testing $REPO"
			if [ -f ${REPO_DIR}/pom.xml ]
			then
				pushd ${REPO_DIR}
				echo "Working up here [`pwd`], REPO_DIR=${REPO_DIR}"

				# echo;logger "Setting latest parent"
				# $M2_HOME/bin/mvn clean versions:update-parent
				# if [ $? -ne 0 ]
				# then
					# abort "Runnig mvn clean versions:update-parent failed"
				# fi

				echo;logger "Running whitesource:update"
				$M2_HOME/bin/mvn whitesource:update
				if [ $? -ne 0 ]
				then
					logger "Failed mvn on $REPO"
					abort "$REPO: Failed mvn on $REPO"
				fi
				popd
			else
				logger "There is no $REPO/pom.xml. Skipping maven build"
			fi
		fi
	else
		logger "$REPO is not a directory"
	fi
done

