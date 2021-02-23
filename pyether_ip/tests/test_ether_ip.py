import pytest
from random import random, randrange

from pyether_ip.eip_client import Client
from pyether_ip.eip_driver import EIPDriver
from pyether_ip.eip_driver import test_copy_python_string

def test_string_copying():
    assert test_copy_python_string("hello") 
    assert test_copy_python_string("hello\r") 
    assert test_copy_python_string("hello\n\t\r") 

max_sint = 2**7-1
min_sint = -2**7
max_int = 2**15-1
min_int = -2**15
max_dint = 2**31-1
min_dint = -2**31
max_real = (2 - 2**-23) * 2**127
min_real = -(2 - 2**-23) * 2**127
min_pos_real = 2**-126


@pytest.fixture
def drv():
    return EIPDriver('172.23.243.77')


def get_test_tag(dtype):
    tags = {
        "sint"   : "SINT_Test",
        "int"    : "INT_Test",
        "dint"   : "DINT_Test",
        "real"   : "REAL_Test",
        "string" : "STRING39_Test",
    }
    if dtype not in tags:
        raise ValueError("dtype not supported: " + dtype)
    return tags[dtype]


dtype_d = [("sint", d) for d in [min_sint, max_sint, 0]] +\
          [("int", d) for d in [min_int, max_int, 0]] +\
          [("dint", d) for d in [min_dint, max_dint, 0]] +\
          [("real", d) for d in [min_real, max_real, min_pos_real, 0.0]]

@pytest.mark.parametrize("dtype,d", dtype_d)
def test_write_read_simple(drv, dtype, d):
    tag = get_test_tag(dtype)
    expected = d
    drv.write_simple(tag, expected, dtype=dtype)
    result = drv.read_tag(tag, dtype=dtype)
    assert expected == result

def test_reading_int_from_driver(drv):
    i = drv.read_tag('PLC_Interface[23].Num', dtype="int")
    assert i == 23

def test_reading_double_from_driver(drv):
    d = drv.read_tag('V[1].Position', dtype="real")
    assert isinstance(d, float)

def test_reading_string_from_driver(drv):
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