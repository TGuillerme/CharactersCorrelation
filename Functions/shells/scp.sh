# Script for copying from the cluster

user=$1
chain=$2

FROMUSER="${user}@awoonga.qriscloud.org.au"
FROMPATH="/90days/${user}/"

scp ${FROMUSER}:${FROMPATH}/${chain}.* .