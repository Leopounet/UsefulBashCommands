from __future__ import annotations

import subprocess
import queue
import time
import re
import os
import subprocess
import select

from typing import Union, List

class Output:
    
    def __init__(self : Output, output : Union[str, bytes], timeout : bool) -> Output:
        self.output : Union[str, bytes] = output
        self.timeout : bool = timeout
        self.encoded : bool = True if isinstance(self.output, bytes) else False
        
    def encode(self : Output) -> Output:
        if not self.encoded: self.output = self.output.encode("utf-8")
        self.encoded = True
        return self
    
    def decode(self : Output) -> Output:
        if self.encoded: self.output = self.output.decode("utf-8")
        self.encoded = True
        return self
    
    def split(self : Output, delim : str) -> List[Output]:
        outputs = []
        for line in self.output.split(delim):
            outputs.append(Output(line, self.timeout))
        return outputs
    
    def strip(self : Output, chars : str) -> Output:
        self.output.strip(chars)
        return self
    
    def isempty(self : Output) -> bool:
        if self.output == "" or self.output == b"": return True
        return False
    
    def remove_special_bytes(self : Output) -> Output:
        # Define the regex pattern to match the escape sequences
        pattern = r'\x1b\[[0-9;]*[A-Za-z]'

        # Use re.sub to replace the escape sequences with an empty string
        self.output = re.sub(pattern, '', self.output)
        
        pattern = r'\x1b\(\w'
        
        # Use re.sub to replace the escape sequences with an empty string
        self.output = re.sub(pattern, '', self.output)
        return self
        
    @staticmethod
    def get_output(process : subprocess.Popen[str], out_queue : queue.Queue, exit_str : Union[str, None] = None, timeout : int = 2) -> Output:
        start_time = time.time()
        output = ""
        while ((process.poll() is None or not out_queue.empty()) and 
            (exit_str is None or not exit_str in output) and 
            time.time() - start_time < timeout):
            try:
                output += out_queue.get(timeout=0.01)  # Use a small timeout for non-blocking behavior
                to_exit = True
            except queue.Empty:
                pass
        return Output(output, time.time() - start_time >= timeout)
    
    @staticmethod
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
    
    def copy(self : Output) -> Output:
        return Output(self.output, self.timeout)
    
    def __add__(self : Output, other : Output) -> Output:
        if self.encoded and not other.encoded: raise ValueError
        if not self.encoded and other.encoded: raise ValueError
        return Output(self.output + other.output, self.timeout or other.timeout)
    
    def __str__(self : Output) -> str:
        return str(self.output)