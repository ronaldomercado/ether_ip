from client import Client

def test_int_reading():
    i = Client.get_int('PLC_Interface[23].Num', '172.23.243.77')
    assert isinstance(i, int)

