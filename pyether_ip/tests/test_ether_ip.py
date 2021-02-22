import pytest
from random import random

from pyether_ip.eip_client import Client
from pyether_ip.eip_driver import EIPDriver
from pyether_ip.eip_driver import test_copy_python_string

def is_close(f1, f2, epsilon=10**-7):
    return abs(f1 - f2) <= epsilon

def test_string_copying():
    assert test_copy_python_string("hello") 
    assert test_copy_python_string("hello\r") 
    assert test_copy_python_string("hello\n\t\r") 

def test_write_T_CIP_REAL():
    drv = EIPDriver('172.23.243.77')
    expected = random()
    drv.write_simple('V[1].User_Set_Position', expected)
    result = drv.read_tag('V[1].User_Set_Position', dtype="double")
    assert is_close(expected, result)

def test_reading_int_from_driver():
    drv = EIPDriver('172.23.243.77')
    i = drv.read_tag('PLC_Interface[23].Num')
    assert i == 23

def test_reading_double_from_driver():
    drv = EIPDriver('172.23.243.77')
    d = drv.read_tag('V[1].Position', dtype="double")
    assert isinstance(d, float)

def test_reading_string_from_driver():
    drv = EIPDriver('172.23.243.77')
    s = drv.read_tag('V[1].Interface_Desc0', dtype="string")
    assert isinstance(s, str)
    assert s == "Valve"

def test_rasie_ConnectionError_for_invalid_ip():
    with pytest.raises(ConnectionError):
        drv = EIPDriver('172.23.243.7774hello')

################################################

def test_int_reading():
    i = Client.get_int('PLC_Interface[23].Num', '172.23.243.77')
    assert isinstance(i, int)

def test_string_reading():
    s = Client.get_string('V[1].Interface_Desc0', '172.23.243.77')
    assert isinstance(s, str)
    assert s == "Valve"

def test_double_reading():
    d = Client.get_double('V[1].Position', '172.23.243.77')
    assert isinstance(d, float)

def test_mismatch_type_raises_exception():
    with pytest.raises(Exception):
        Client.get_int('V[1].Interface_Desc0', '172.23.243.77') # V[]..Desc0 stores a string