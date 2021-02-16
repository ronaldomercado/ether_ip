import pytest

from eip_client import Client

def test_int_reading():
    i = Client.get_int('PLC_Interface[23].Num', '172.23.243.77')
    assert isinstance(i, int)

def test_string_reading():
    s = Client.get_string('V[1].Interface_Desc0', '172.23.243.77')
    assert isinstance(s, str)

def test_double_reading():
    d = Client.get_double('V[1].Position', '172.23.243.77')
    assert isinstance(d, float)

def test_mismatch_type_raises_exception():
    with pytest.raises(Exception):
        Client.get_int('V[1].Interface_Desc0', '172.23.243.77') # V[]..Desc0 stores a string