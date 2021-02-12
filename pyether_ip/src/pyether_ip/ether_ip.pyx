cdef extern from "ether_ip_ctest.h":
    int read_int_from_tag(const char* tag, const char* ip)
    double read_double_from_tag(const char* tag, const char* ip)
    void read_string_from_tag(const char *tag, const char *ip, char* buffer, int size)

def get_bytes(string):
    if isinstance(string, bytes):
        return string
    elif isinstance(string, str):
        return string.encode("utf-8")
    else:
        raise ValueError("input must be of type str or bytes")

def get_double(tag, ip):
    tag = get_bytes(tag)
    ip = get_bytes(ip)
    return read_double_from_tag(tag, ip)

def get_int(tag, ip):
    tag = get_bytes(tag)
    ip = get_bytes(ip)
    return read_int_from_tag(tag, ip)

cpdef char* get_string(tag, ip):
    cdef int size = 40
    cdef char result[40]
    tag = get_bytes(tag)
    ip = get_bytes(ip)
    read_string_from_tag(tag, ip, result, size)
    return result