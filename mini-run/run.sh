#!/usr/bin/env bash

NODE_NAME_PREFIX="p-ambari"
let N=5
let PORT=8085
let S=0

function usage() {
    echo "Usage: ./run.sh [--nodes=3] [--port=8080] [--secure]"
    echo
    echo "--nodes      Specify the number of total nodes"
    echo "--port       Specify the port of your local machine to access Ambari Web UI (8080 - 8088)"
    echo "--secure     Specify the cluster to be secure"
}

# Parse and validate the command line arguments
function parse_arguments() {
    while [ "$1" != "" ]; do
        PARAM=`echo $1 | awk -F= '{print $1}'`
        VALUE=`echo $1 | awk -F= '{print $2}'`
        case $PARAM in
            -h | --help)
                usage
                exit
                ;;
            --port)
                PORT=$VALUE
                ;;
            --nodes)
                N=$VALUE
                ;;
            --secure)
                S=1
                ;;
            *)
                echo "ERROR: unknown parameter \"$PARAM\""
                usage
                exit 1
                ;;
        esac
        shift
    done
}

parse_arguments $@

# launch containers
master_id=$(docker run -dit --net devnet -p $PORT:8080 -p 6080:6080 -p 9090:9090 -p 9000:9000 -p 2181:2181 -p 8000:8000 -p 8020:8020 -p 42111:42111 -p 10500:10500 -p 16030:16030 -p 8042:8042 -p 8040:8040 -p 2100:2100 -p 4200:4200 -p 4040:4040 -p 8050:8050 -p 9996:9996 -p 9995:9995 -p 8088:8088 -p 8886:8886 -p 8889:8889 -p 8443:8443 -p 8744:8744 -p 8890:8888 -p 8188:8188 -p 8983:8983 -p 1000:1000 -p 1100:1100 -p 11000:11000 -p 10001:10001 -p 15000:15000 -p 10000:10000 -p 8993:8993 -p 1988:1988 -p 5007:5007 -p 50070:50070 -p 19888:19888 -p 16010:16010 -p 50111:50111 -p 50075:50075 -p 18080:18080 -p 60000:60000 -p 8090:8090 -p 8091:8091 -p 8005:8005 -p 8086:8086 -p 8082:8082 -p 60080:60080 -p 8765:8765 -p 5011:5011 -p 6001:6001 -p 6003:6003 -p 6008:6008 -p 1220:1220 -p 21000:21000 -p 6188:6188 -p 2222:22 -p 50010:50010 -p 6667:6667 -p 3001:3000 --name $NODE_NAME_PREFIX-0 p-ambari /bin/bash )
echo ${master_id:0:12} > hosts
for i in $(seq $((N-1)));
do
    container_id=$(docker run -dit --net devnet --name $NODE_NAME_PREFIX-$i p-ambari /bin/bash)
    echo ${container_id:0:12} >> hosts
done

# Copy the workers file to the master container
docker cp hosts $master_id:/root
# print the hostnames
echo "Using the following hostnames:"
echo "------------------------------"
cat hosts
echo "------------------------------"

# print the private key
echo "Copying back the private key..."
docker cp $master_id:/root/.ssh/id_rsa .
echo "------------------------------"

echo "Starting ssh and ntp..."
echo "------------------------------"
for i in $(seq $((N-1)));
do
    docker exec $NODE_NAME_PREFIX-$i service ntp start && docker exec $NODE_NAME_PREFIX-$i service ssh start
done
echo "------------------------------"

docker exec $NODE_NAME_PREFIX-0
# Start the ambari server
docker exec $NODE_NAME_PREFIX-0 ambari-server start
