    docker run -d -e "HUB_PORT_4444_TCP_ADDR=<hub_ip>" -e "HUB_PORT_4444_TCP_PORT=<hub_port>" -e "NODE_HOST=<node_ip>" -e "NODE_PORT=<node_port>" -e "MAX_INSTANCES=5" --net host varokas/selenium-node:3.0.1-fermium

