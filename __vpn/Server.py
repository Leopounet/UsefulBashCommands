from __future__ import annotations

from typing import List, Union

class Server:
    
    def __init__(self : Server, line : str) -> Server:
        lines : List[str] = line.strip(" ").split("|")[0].split("Load:")
        self.name : str = lines[0]
        self.load : int = int(lines[1].strip(" \t\n%|"))
        
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