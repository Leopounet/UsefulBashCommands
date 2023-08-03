from __future__ import annotations
import subprocess
import threading
import queue
import time
import pty
import os
import subprocess
import select
import time
import re
import sys
from enum import Enum

from typing import List, Union

class Country(Enum):
    US = ("us", "united states")
    JP = ("jp", "japan")
    NL = ("nl", "netherlands")
    
def get_country(arg : str) -> Country:
    for country in Country:
        if arg in country.value: return country
    return Country.NL

class Server:
    
    def __init__(self : Server, line : str) -> Server:
        lines : List[str] = line.split("  ")
        self.name : str = lines[0]
        self.load : int = int(lines[2].strip(" \t\n%|"))
        
    @staticmethod
    def get_server(line : str) -> Union[Server, None]:
        try:
            return Server(line)
        except Exception as e:
            pass
        return None
        
    def __eq__(self : Server, other : Server) -> bool:
        return self.name == other.name
    
    def __hash__(self : Server) -> int:
        return hash((self.name, self.load))
    
    def __str__(self : Server) -> str:
        return f"{self.name} : {self.load}%"

def remove_special_bytes(byte_sequence : str) -> str:
    # Define the regex pattern to match the escape sequences
    pattern = r'\x1b\[[0-9;]*[A-Za-z]'

    # Use re.sub to replace the escape sequences with an empty string
    clean_sequence = re.sub(pattern, '', byte_sequence)
    
    pattern = r'\x1b\(\w'
    
    # Use re.sub to replace the escape sequences with an empty string
    clean_sequence = re.sub(pattern, '', clean_sequence)

    return clean_sequence

def read_output(master : int, output_queue : queue.Queue) -> None:
    while True:
        try:
            r, _, _ = select.select([master], [], [], 0.1)
            if r:
                data = os.read(master, 1024).decode("utf-8")
                if data:
                    output_queue.put(data)
                else:
                    break
        except OSError:
            break
        
def get_output(process : subprocess.Popen[str], out_queue : queue.Queue, timeout : int = 2) -> str:
    start_time = time.time()
    output = ""
    while (process.poll() is None or not out_queue.empty()) and time.time() - start_time < timeout:
        try:
            output += out_queue.get(timeout=0.01)  # Use a small timeout for non-blocking behavior
        except queue.Empty:
            pass
    return output

def interact_with_terminal(command_with_args : List[str], country : country):
    master, slave = pty.openpty()

    p = subprocess.Popen(command_with_args, stdin=slave, stdout=slave, stderr=subprocess.STDOUT, universal_newlines=True, bufsize=1)
    os.close(slave)

    output_queue = queue.Queue()
    output_thread = threading.Thread(target=read_output, args=(master, output_queue))
    output_thread.daemon = True
    output_thread.start()
        
    get_output(p, output_queue)
    if country != Country.JP: os.write(master, b'\x1bOB')
    get_output(p, output_queue, timeout=0.1)
    if country != Country.NL and country != Country.JP: os.write(master, b'\x1bOB')
    get_output(p, output_queue, timeout=0.1)
    os.write(master, "\n".encode())
    get_output(p, output_queue)
    
    output = ""
    for i in range(100):
        os.write(master, b'\x1bOB')
        output += get_output(p, output_queue, timeout=0.1)
    
    output = remove_special_bytes(output).split("Free |")
    servers : List[Server] = []
    for line in output:
        line = line.strip("\t \n")
        if line == "": continue
        server = Server.get_server(line)
        if server is not None and server not in servers: 
            servers.append(server)
        
    
    best = min(servers, key = lambda server: server.load)
    index = servers.index(best)
    
    
    for i in range(0, len(servers) - index - 2):
        os.write(master, b'\x1bOA')
        get_output(p, output_queue, timeout=0.2)
        
    if index != len(servers) - 1: os.write(master, b'\x1bOA')
    os.write(master, "\n".encode())
    get_output(p, output_queue, timeout=2)
    os.write(master, "\n".encode())
    
    time.sleep(10)
            
    os.close(master)
    p.wait()
    output_thread.join()

# Example usage with arguments and a timeout of 10 seconds:
command_with_args = ["protonvpn-cli", "connect"]

countries = [
    ("jp", "Japan"),
    ("us", "United States"),
    ("nl", "Netherlands")
]

country = Country.NL
if len(sys.argv) >= 2: country = get_country(sys.argv[1])
interact_with_terminal(command_with_args, country)