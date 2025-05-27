# #!/bin/bash

function running_caller() {
    local function_name="${1}"
    local args="${@:2}"
    if type $function_name &>/dev/null; then
        # echo "Running function: '${function_name}'"
        $function_name $args
    else
        echo "Function '${function_name}' not found."
        return 1
    fi
    for i in {1..3}; do
        printf '.' > /dev/tty
        sleep 1
    done
}

function job() {
    local arg1="${1:-default_arg1}"
    local arg2="${2:-default_arg2}"
    echo "Running job with arguments: $arg1, $arg2"
    for i in {1..5}; do
        # echo $i
        sleep 1
    done
}

dotpid=
rundots() { ( trap 'exit 0' SIGUSR1; while : ; do printf '.' >&2; sleep 1; done) &  dotpid=$!; }
stopdots() { kill -USR1 $dotpid; wait $dotpid; trap EXIT; }
startdots() { rundots; trap "stopdots" EXIT; return 0; }

longproc() {
    echo 'Start doing something long... (5 sec sleep)'
    sleep 5
    echo
    echo 'Finished the long job'
}


run() {
    startdots
    # job "arg1_value" "arg2_value"
    longproc
    stopdots
}

run

# read -p "Update your system? [y/n]" RESP
# if [ "$RESP" = "y" ] || [ "$RESP" = "Y" ] || [ "$RESP" = "Yes" ] || [ $RESP = "yes" ]; then
#     echo "Loading..." #dot loop to show that process is occurring    
#     # sudo apt-get update>>log.txt 2>&1 #when complete want the dots to stop looping.
#     loop
#     echo "----------------------------------------------------------------------------------------------------------------------------------------------------">>log.txt 2>&1
#     echo "----------------------------------------------------------------------------------------------------------------------------------------------------">>log.txt 2>&1
#     echo "Status=$?"    
#     echo "Done"
#     sleep 2
#     clear
# else
#     echo "OK"
# fi
