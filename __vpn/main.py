from __future__ import annotations
import subprocess
import threading
import queue
import time
import pty
import os
import subprocess
import time
import sys

from typing import List
from Server import Server
from Country import Country
from Output import Output
from Keys import Keys

import requests

def connected_to_internet(url='http://www.google.com/', timeout=5):
    try:
        _ = requests.head(url, timeout=timeout)
        return True
    except requests.ConnectionError:
        pass
    return False


def interact_with_terminal(command_with_args : List[str], country : Country):
    # call to protonvpn-cli
    master, slave = pty.openpty()
    p = subprocess.Popen(command_with_args, stdin=slave, stdout=slave, stderr=subprocess.STDOUT, universal_newlines=True, bufsize=1)
    os.close(slave)

    # used to gather data during the execution of protonvpn-cli
    output_queue = queue.Queue()
    output_thread = threading.Thread(target=Output.read_output, args=(master, output_queue))
    output_thread.daemon = True
    output_thread.start()
        
    # wait for the page to load
    Output.get_output(p, output_queue, "OK")
    
    # select the correct country
    for _ in range(Country.pos(country)): os.write(master, Keys.DOWN_ARROW.value)
    os.write(master, Keys.ENTER.value)
    
    # get every available server
    output = Output("", False)
    while True:
        
        # wait for the servers to load
        output += Output.get_output(p, output_queue, "Load:", timeout=2)
            
        # if the gathering has been timed out, it means
        # that there are no more data to collect
        if output.timeout: break
        
        # press the down arrow to get the next servers (if any)
        os.write(master, Keys.DOWN_ARROW.value)
        
    # print(output)
                    
    # the list of outputs, trimmed so that
    # there are basically only what is interesting    
    outputs = output.remove_special_bytes().split(Country.code(country))
    
    # the list of servers ordered
    servers : List[Server] = []
    
    # parse all the trimmed outputs
    for output in outputs:
        
        # trim even more and add back the country code that was removed
        # (technically useless but it's for my OCD)
        output = Output(Country.code(country), False) + output.split("|")[0]
        output = output.strip("\t \n")
        
        # if we are left we the empty string, we can skip it
        if output.isempty(): continue
        
        # otherwise we add the server to the list (if it was not already in)
        server = Server.get_server(output.output)
        if server is not None and server not in servers: 
            servers.append(server)
        
    # get the index of the best server
    best = min(servers, key = lambda server: server.load)
    index = servers.index(best)
        
    # press the up arrow as many times as required
    # to reach the correct server (to read them all we got
    # to the bottom)
    for i in range(0, len(servers) - index - 2):
        os.write(master, Keys.UP_ARROW.value)
        Output.get_output(p, output_queue, timeout=0.01)
    
    # one more click is required (unless no clicks were required!)
    if index != len(servers) - 1: os.write(master, Keys.UP_ARROW.value)
    Output.get_output(p, output_queue, timeout=0.01)
    
    # select the server and then select the mode (UDP)
    os.write(master, Keys.ENTER.value)
    Output.get_output(p, output_queue, timeout=2)
    os.write(master, Keys.ENTER.value)

    # wait until the connection is established (10 seconds
    # is more than enough)    
    time.sleep(10)

    # close nicely
    os.close(master)
    p.wait()
    output_thread.join()
    
# Example usage with arguments and a timeout of 10 seconds:
time.sleep(10)

# make sure there is an internet connection
no_internet = True
for i in range(10):
    if connected_to_internet(): no_internet = False; break
    time.sleep(10)
if no_internet: exit(-1)

for i in range(10):
    try:
        command_with_args = ["protonvpn-cli", "connect"]
        country = Country.NL
        if len(sys.argv) == 2: country = Country.get_country(sys.argv[1])
        interact_with_terminal(command_with_args, country)
        exit(0)
    except Exception as e:
        pass
exit(-1)