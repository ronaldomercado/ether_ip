import pytest
from random import random, randrange

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
        "bool"   : "BOOL_Test",
        "sint"   : "SINT_Test",
        "int"    : "INT_Test",
        "dint"   : "DINT_Test",
        "real"   : "REAL_Test",
        "string" : "STRING39_Test",
        "word"   : "WORD_Test",
        "dword"  : "DWORD_Test",
        "string" : "STRING39_Test"
    }
    if dtype not in tags:
        raise ValueError("dtype not found: " + dtype)
    return tags[dtype]


dtype_d = [("sint", d) for d in [min_sint, max_sint, 0]] +\
          [("int", d) for d in [min_int, max_int, 0]] +\
          [("dint", d) for d in [min_dint, max_dint, 0]] +\
          [("real", d) for d in [min_real, max_real, min_pos_real, 0.0]] +\
          [("word", d) for d in [b"\x00\x00", b"\x10\x10"]] +\
          [("dword", d) for d in [b"\x00\x00\x22\x33", b"\x10\x10\x11\x11"]] +\
          [("bool", d) for d in [0, 1, True, False]] +\
          [("string", d) for d in [b"", b"hello", b"bye"]]

@pytest.mark.parametrize("dtype,d", dtype_d)
def test_write_read(drv, dtype, d):
    tag = get_test_tag(dtype)
    expected = d
    drv.write(tag, expected, dtype=dtype)
    result = drv.read(tag, dtype=dtype)
    assert expected == result


def test_rasie_ConnectionError_for_invalid_ip():
    with pytest.raises(ConnectionError):
        drv = EIPDriver('172.23.243.7774hello')