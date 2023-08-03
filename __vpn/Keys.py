from enum import Enum

class Keys(Enum):
    DOWN_ARROW = b'\x1bOB'
    UP_ARROW = b'\x1bOA'
    ENTER = b'\n'