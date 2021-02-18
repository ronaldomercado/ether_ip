cdef extern from "<ether_ip.h>":
    ctypedef signed char    CN_SINT
    ctypedef unsigned char  CN_USINT
    ctypedef unsigned short CN_UINT
    ctypedef short          CN_INT
    ctypedef unsigned int   CN_UDINT
    ctypedef int            CN_DINT
    ctypedef float          CN_REAL

    ctypedef struct EIPConnection:
        pass
    EIPConnection* EIP_init()

    ctypedef struct ParsedTag:
        pass
    ParsedTag *EIP_parse_tag(const char *tag)
    void EIP_copy_ParsedTag(char *buffer, const ParsedTag *tag)
    void EIP_free_ParsedTag(ParsedTag *tag)

    bint EIP_startup(EIPConnection *c,
                 const char *ip_addr, unsigned short port,
                 int slot,
                 size_t millisec_timeout)

    const CN_USINT* EIP_read_tag(EIPConnection *c,
                             const ParsedTag *tag, size_t elements,
                             size_t *data_size,
                             size_t *request_size, size_t *response_size)


    void EIP_shutdown (EIPConnection *c)
    void EIP_dispose(EIPConnection *c)

    void dump_raw_CIP_data(const CN_USINT *raw_type_and_data, size_t elements);
    bint get_CIP_double(const CN_USINT *raw_type_and_data,
                        size_t element, double *result);
    bint get_CIP_UDINT(const CN_USINT *raw_type_and_data,
                    size_t element, CN_UDINT *result);
    bint get_CIP_DINT(const CN_USINT *raw_type_and_data,
                    size_t element, CN_DINT *result);
    bint get_CIP_USINT(const CN_USINT *raw_type_and_data,
                        size_t element, CN_USINT *result);

    # Fill buffer with up to 'size' characters (incl. ending '\0').
    # Return true for success
    bint get_CIP_STRING(const CN_USINT *raw_type_and_data,
                        char *buffer, size_t size);
    bint put_CIP_double(const CN_USINT *raw_type_and_data,
                        size_t element, double value);
    bint put_CIP_UDINT(const CN_USINT *raw_type_and_data,
                    size_t element, CN_UDINT value);
    bint put_CIP_DINT(const CN_USINT *raw_type_and_data,
                    size_t element, CN_DINT value);

    # Fill raw_type_and_data with data and data length.  Leave
    # the other portion of it unchanged.
    bint put_CIP_STRING(const CN_USINT *raw_type_and_data,
                    char *value, size_t size);

from libc.stdio cimport printf
from libc.stdlib cimport malloc, free
from libc.string cimport strcpy, strlen

DEBUG = True

cdef class EIPDriver:
    cdef EIPConnection* _conn
    cdef bytes _ip # needs to stay alive until class instance is cleaned up

    def __cinit__(self, ip):
        self._conn = EIP_init()
        if self._conn is NULL:
            raise MemoryError()


    def __dealloc__(self):
        if self._conn is not NULL:
            EIP_shutdown(self._conn)
            EIP_dispose(self._conn)


    def __init__(self, ip, port=0xAF12, slot=0, timeout_ms=5000):
        self._ip = bytes(ip)
        success = EIP_startup(self._conn, self._ip, port, slot, timeout_ms)
        print(success)
        if not success:
            raise ConnectionError("could not connect to " + str(ip))
        print("eip driver initialized")

    def read_tag(self, tag, elements=1, dtype="int"):
        cdef int string_size = 40   # ordinarily we would use a macro to set this
        cdef char string_result[40] # unfortunately cython does not support preprocessor macros
        if dtype not in ["int", "double", "string"]:
            raise ValueError("unsupported type: " + dtype)

        cdef ParsedTag* parsed_tag = EIP_parse_tag(tag)
        if parsed_tag == NULL:
            raise RuntimeError("Failed to parse the tag " + tag.decode())
        cdef size_t data_len, request_size, response_size
        cdef const CN_USINT *data = EIP_read_tag(self._conn,
                                                 parsed_tag,
                                                 elements,
                                                 &data_len,
                                                 &request_size,
                                                 &response_size)
        if data == NULL:
            raise RuntimeError("could not get data")
        if DEBUG:
            dump_raw_CIP_data(data, elements)
        EIP_free_ParsedTag(parsed_tag)

        if dtype == "int":
            return self._get_cip_dint(data, 0)
        elif dtype == "double":
            return self._get_cip_double(data, 0)
        elif dtype == "string":
            success = get_CIP_STRING(data, string_result, string_size)
            if not success:
                raise RuntimeError("could not get string from data")
            return string_result.decode()
        else:
            raise RuntimeError("illegal state: dtype not supported")
        
    cdef int _get_cip_dint(self,
                           const CN_USINT *raw_type_and_data,
                           size_t element):
        cdef int result
        success = get_CIP_DINT(raw_type_and_data, element, &result)
        if not success:
            raise RuntimeError("could not get dint from data")
        return result

    cdef double _get_cip_double(self,
                           const CN_USINT *raw_type_and_data,
                           size_t element):
        cdef double result
        success = get_CIP_double(raw_type_and_data, element, &result)
        if not success:
            raise RuntimeError("could not get double from data")
        return result