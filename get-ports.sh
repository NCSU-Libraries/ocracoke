#
# Grab the ports from the VM info details.
#

# check if the parameter provided is OK
if ! VBoxManage showvminfo $1 &> /dev/null; then
    exit
fi

echo " "
echo " "

# set up some helper variables
LINE="                                        "
TCP_TIMEOUT=1
DEPLOYMENTS_DOWN=
INDEX=0
# vagrant outputs in bold so set the value for resetting
# and make sure we are in bold as well
BOLD=""
if tput colors &> /dev/null; then
    BOLD="$(tput bold)"
fi
echo "${BOLD}"


# start with the HTTP port
HTTP_PORT=`VBoxManage showvminfo $1 --details | grep "guest port = 80" | sed 's/.*host port = \([0-9]*\).*/\1/'`
if [ -z "$HTTP_PORT" ]; then
    HTTP_PORT="80"
fi

# get all deployments used on this vagrant box (grabs the $DEPLOYMENTS array)
# source `dirname "$BASH_SOURCE"`/deployments.sh
DEPLOYMENTS="system1.local
default"

(
    # list all deployment URLs with the correct ports
    echo "Available deployments can be accessed on the following URLs:"
    for DEPLOYMENT in $DEPLOYMENTS
    do
        URL="http://$DEPLOYMENT"
        if [ "$HTTP_PORT" -ne "80" ]; then
            URL="$URL:$HTTP_PORT"
        fi

        # check the host/port (allow 0.1s before timing out)
        (
            # pre bash 4 (e.g. on a mac) need to use a workaround to get the pid
            if [ -z $BASHPID ]; then
                F='/tmp/bashpid'; echo 'echo $PPID' > $F; BASHPID=`bash $F`; rm $F
            fi

            PID_TO_KILL=$BASHPID;
            (sleep 0.1; kill $PID_TO_KILL) & exec 3<> /dev/tcp/$DEPLOYMENT/$HTTP_PORT
        ) 2>/dev/null

        # return value 0=OK, 1=DOWN, 143=TIMEDOUT
        if [ $? -eq 0 ]; then
            printf "    %s %s [ \e[1;32m UP \e[0m ${BOLD}]\n" "$URL" "${LINE:${#URL}}"
        else
            printf "    %s %s [ \e[1;31mDOWN\e[0m ${BOLD}]\n" "$URL" "${LINE:${#URL}}"
            DEPLOYMENTS_DOWN[$INDEX]=$DEPLOYMENT
            let INDEX+=1
        fi
    done

    # in case any deployments are inaccessible then list the /etc/hosts line
    if [ ${#DEPLOYMENTS_DOWN[@]} -gt 0 ]; then
        echo " "
        echo "Some deployments appear to not be accessible."
        echo "Consider adding the following lines to your /etc/hosts file:"
        printf '    127.0.0.1    %s\n' "${DEPLOYMENTS_DOWN[@]}"
    fi

) 2>/dev/null # supress the "Terminated" messages in case the /dev/tcp check is killed

echo " "

# then show the SSH port
SSH_PORT=`VBoxManage showvminfo $1 --details | grep "guest port = 22" | sed 's/.*host port = \([0-9]*\).*/\1/'`

if [ -z "$SSH_PORT" ] || [ $SSH_PORT -eq "22" ]; then
    SSH_PORT=""
else
    SSH_PORT=" -p $SSH_PORT"
fi

echo "You can ssh into the machine in one of the following ways:"
COMMAND="vagrant ssh"
printf "    %s %s (within the vagrant directory)\n" "$COMMAND" "${LINE:${#COMMAND}}"
COMMAND="ssh vagrant@localhost$SSH_PORT"
printf "    %s %s (from anywhere)\n" "$COMMAND" "${LINE:${#COMMAND}}"
COMMAND="ssh root@localhost$SSH_PORT"
printf "    %s %s (from anywhere)\n" "$COMMAND" "${LINE:${#COMMAND}}"

echo " "
echo " "
