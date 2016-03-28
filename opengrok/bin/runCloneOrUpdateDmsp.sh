#!/bin/bash

OPENGROK_HOME=/opt/opengrok
ROOT_WORKSPACE=$OPENGROK_HOME/src
OPENGROK_LOG=$OPENGROK_HOME/logs

. $OPENGROK_HOME/bin/utils.sh
. $OPENGROK_HOME/bin/lockingUtils.sh

PRODUCT_LIST="dmsp siberia"
GIT_PROJECT_LIST="dmsp nmda nanx"

REPO_IGNORE_LIST="_dummy scripts dmsp-idtv-ios-client dmsp-adtv-demo-client-events"

SCRIPT_PID=$$
#log File
LOG_FILE="${0}.log"
#Lock File
LOCK_FILE="${0}.lck"

MERCURIAL_IP=10.35.25.27

prepareHg()
{
	FOSS_PRODUCT=$1
	if [ -z "$FOSS_PRODUCT" ]
	then
		logger "ERROR: FOSS_PRODUCT is not set. Aborting"
		exit 1
	fi

	REPO_DIR=$FOSS_PRODUCT
	REPO_LIST_FILE=$FOSS_PRODUCT.repository.list

	# Remover errors log if exists from last run
	rm -f $OPENGROK_LOG/errors.log

	#logger "Removing $ROOT_WORKSPACE/$REPO_DIR"
	#rm -rf $ROOT_WORKSPACE/$REPO_DIR
	mkdir -p $ROOT_WORKSPACE/$REPO_DIR

	touch $OPENGROK_HOME/logs/script.runs.now
	#ssh $SSH_OPTS $MERCURIAL_IP "cd $HG_SERVER_FS_ROOT/$FOSS_PRODUCT; ls -1" > $ROOT_WORKSPACE/$REPO_LIST_FILE
	if [ $? -ne 0 ]
	then
		abort "Failed getting repository list"
	fi

	cd $ROOT_WORKSPACE/$REPO_DIR

	echo
	logger "Preparing Mercurial repositories"

	# For each repo, clone or update repository
	for REPO in `cat $ROOT_WORKSPACE/$REPO_LIST_FILE`
	do
		echo
		if [[ ! $REPO_IGNORE_LIST =~ $REPO ]]
		then
			if [ -d $REPO ]
			then
				logger "Repository $REPO already exists. Removing it"
				rm -rf $REPO
			fi

			logger "Cloning $REPO"
			hg clone $HG_BASE/$REPO $REPO > /dev/null &
			if [ $? -ne 0 ]
			then
				abort "Failed cloning $REPO"
			fi

			sleep 0.5
		else
			logger "Skipping $REPO. Removing it from repository list"
			sed -i "/$REPO/d" $ROOT_WORKSPACE/$REPO_LIST_FILE
		fi
	done

	rm $ROOT_WORKSPACE/$REPO_LIST_FILE

}

prepareGit()
{
	echo
        if [ -z "$1" ]
        then
                abort "Must pass a Git project"
        fi

	#logger "Removing $ROOT_WORKSPACE/$1"
	#rm -rf $ROOT_WORKSPACE/$1

	mkdir -p $ROOT_WORKSPACE/$1
	cd $ROOT_WORKSPACE/$1

	echo
	logger "Getting Git repositories for $1"

	for LINE in $(python $OPENGROK_HOME/bin/getGitRepos.py $P)
	do
		REPO_NAME=$(echo $LINE | awk -F= '{print $1}')
		REPO_URL=$(echo $LINE | awk -F= '{print $2}')
		logger "Processing $REPO_NAME"

		#logger "Name: $REPO_NAME, Clone URL: $REPO_URL"
		REPO_NAME=$(echo -n $REPO_NAME | tr '[A-Z]' '[a-z]')
		logger "Checking if $REPO_NAME exists"
		if [ -d $REPO_NAME ]
		then
			logger "$REPO_NAME exists. Removing it"
			rm -rf $REPO_NAME
		fi

		logger "Cloning $REPO_NAME"
		#git clone $REPO_URL > /dev/null &
		git clone $REPO_URL
		if [ $? -ne 0 ]
		then
			abort "Failed cloning $REPO_NAME"
		fi

		sleep 0.5
	done
}

runIndex()
{

	echo
	if [ -z "$1" ]
	then
		abort "Must pass a directory to index"
	fi

	logger "Running the OpenGrok indexing on ${1}"
	touch $OPENGROK_LOG/opengrok.indexing.running
	cd $OPENGROK_HOME/bin
	./OpenGrok index ${1}

}


lockMe "$LOCK_FILE"

#printToLog "LOG FILE=${LOG_FILE}"

# Preparing HG sources
#for P in $PRODUCT_LIST
#do
#	logger "Preparing $P"
#	prepareHg $P
#done

# Preparing Git sources
for P in $GIT_PROJECT_LIST
do
	logger "Preparing $P"
	prepareGit $P
done

# Clean Siberia node_modules directories
logger "Removing node_modules directories"
find $ROOT_WORKSPACE -type d -name node_modules | xargs rm -rf

# Wait for all clone tasks to finish (just sleep now. Need to implement an actual wait loop)
#logger "Waiting 120 mins for clone tasks to finish"
#sleep 120

echo
logger "Finished clone"
echo

runIndex $ROOT_WORKSPACE

unLockMe "$LOCK_FILE"

echo
# Exit with error if needed
if [ -f $OPENGROK_LOG/errors.log ]
then
	logger "Errors found in the following repositories:"
	cat $OPENGROK_LOG/errors.log
	abort "Errors found"
fi


# Cleaning
rm $OPENGROK_LOG/script.runs.now
rm $OPENGROK_LOG/opengrok.indexing.running
rm -f /tmp/tags.*

exit 0
