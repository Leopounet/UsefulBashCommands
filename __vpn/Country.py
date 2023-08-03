from __future__ import annotations
from enum import Enum

class Country(Enum):
    US = ("US", "UNITED STATES")
    JP = ("JP", "JAPAN")
    NL = ("NL", "NETHERLANDS")
    
    @staticmethod
    def get_country(arg : str) -> Country:
        for country in Country:
            if arg.upper() in country.value: return country
        return Country.NL
    
    @staticmethod
    def pos(country : Country) -> int:
        order = [
            Country.JP, Country.NL, Country.US
        ]
        return order.index(country)
    
    @staticmethod
    def code(country : Country) -> str:
        return country.value[0]
        
