cdef extern from "ether_ip_ctest.h":
    bint read_int_from_tag(const char* tag, const char* ip, int* result)
    bint read_double_from_tag(const char* tag, const char* ip, double* result)
    bint read_string_from_tag(const char *tag, const char *ip, char* buffer, int size)

def get_bytes(string):
    if isinstance(string, bytes):
        return string
    elif isinstance(string, str):
        return string.encode("utf-8")
    else:
        raise ValueError("input must be of type str or bytes")

class Client:

    def get_double(tag, ip):
        tag = get_bytes(tag)
        ip = get_bytes(ip)
        cdef double result
        success = read_double_from_tag(tag, ip, &result)
        if not success:
            raise Exception("something went wrong in read_double_from_tag")
        return result

    def get_int(tag, ip):
        tag = get_bytes(tag)
        ip = get_bytes(ip)

        cdef int result
        success = read_int_from_tag(tag, ip, &result)
        if not success:
            raise Exception("something went wrong in read_int_from_tag")
        return result

    def get_string(tag, ip):
        cdef int size = 40
        cdef char result[40]
        tag = get_bytes(tag)
        ip = get_bytes(ip)
        success = read_string_from_tag(tag, ip, result, size)
        if not success:
            raise Exception("something went wrong in read_string_from_tag")
        return result.decode() # convert to python unicode string