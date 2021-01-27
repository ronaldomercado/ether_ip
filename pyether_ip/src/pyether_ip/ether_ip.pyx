cdef extern from "ether_ip_ctest.h":
    int read_int_from_tag(const char*, const char*)

def ether_ip_read_int_from_tag(tag, ip_address):
    return read_int_from_tag(tag, ip_address)