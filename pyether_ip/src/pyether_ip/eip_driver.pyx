cdef extern from "<ether_ip.h>":
    ctypedef signed char    CN_SINT
    ctypedef unsigned char  CN_USINT
    ctypedef unsigned short CN_UINT
    ctypedef short          CN_INT
    ctypedef unsigned int   CN_UDINT
    ctypedef int            CN_DINT
    ctypedef float          CN_REAL

    ctypedef enum CIP_Type:
        T_CIP_BOOL   = 0x00C1
        T_CIP_SINT   = 0x00C2
        T_CIP_INT    = 0x00C3
        T_CIP_DINT   = 0x00C4
        T_CIP_REAL   = 0x00CA
        T_CIP_WORD   = 0x00D2
        T_CIP_BITS   = 0x00D3
        T_CIP_STRUCT = 0x02A0

    ctypedef enum CIP_STRUCT_Type:
        # T_CIP_STRUCT_STRING = 0x0FCE
        T_CIP_STRUCT_STRING = 0x00D0

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

    bint EIP_write_tag(EIPConnection *c, const ParsedTag *tag,
                   CIP_Type type, size_t elements, CN_USINT *data,
                   size_t *request_size,
                   size_t *response_size);

cimport cython
from libc.stdio cimport printf
from libc.stdlib cimport malloc, free
from libc.string cimport strcpy, strlen, memcpy

DEBUG = True
cdef int MAX_STRING_SIZE = 40



cdef void copy_python_string(char** c_string, unicode py_string):
    cdef bytes py_byte_string = py_string.encode("utf8")
    cdef int n = len(py_byte_string) + 1 # include null terminator '\0' in len
    c_string[0] = <char*>malloc((n)*sizeof(char)) 
    if c_string[0] is NULL:
        raise MemoryError()

    # <char*> informs the cython compiler to get the pointer to the actual bytes string
    # <void*> will get the pointer to the bytes object thus will fail
    # https://stackoverflow.com/a/4453355/14537811
    memcpy(c_string[0], <char*>py_byte_string, n)

def test_copy_python_string(py_string):
    cdef char* c_string
    copy_python_string(&c_string, py_string)
    if not c_string:
        return False
    py_byte_string = c_string
    py_unicode_string = py_byte_string.decode()
    free(c_string)
    return py_unicode_string == py_string
    
@cython.final # prevent subclassing
cdef class EIPDriver:
    cdef EIPConnection* _conn
    cdef char* _ip # needs to stay alive until class instance is cleaned up
    cdef bint _started

    def __cinit__(self, ip, port=0xAF12, slot=0, timeout_ms=5000):
        self._started = False
        self._ip = NULL
        self._conn = NULL

        if not isinstance(ip, unicode):
            raise ValueError("ip must be of type unicode")
        copy_python_string(&(self._ip), ip)
        if self._ip is NULL:
           raise MemoryError()

        self._conn = EIP_init()
        if self._conn is NULL:
            raise MemoryError()

        self._started = EIP_startup(self._conn, self._ip, port, slot, timeout_ms)
        if not self._started:
            raise ConnectionError("could not connect to " + str(self._ip))

    def __dealloc__(self):
        # the order of deallocation matters here
        if self._started:
            EIP_shutdown(self._conn)
        if self._conn is not NULL:
            EIP_dispose(self._conn)
        if self._ip is not NULL:
            free(<void*>(self._ip))


    def write_simple(self, tag, val, dtype):
        if dtype not in ["sint", "int", "dint", "real"]:
            raise ValueError("unsupported type: " + dtype)

        if not isinstance(tag, unicode):
            raise ValueError("tag must be of type unicode")

        cdef bytes btag = tag.encode("utf-8")
        cdef ParsedTag* parsed_tag = EIP_parse_tag(btag)
        if parsed_tag is NULL:
            raise RuntimeError("Failed to parse the tag " + tag)

        cdef CN_REAL real_buffer
        cdef CN_SINT sint_buffer
        cdef CN_INT int_buffer
        cdef CN_DINT dint_buffer
        if dtype == "real":
            real_buffer = <CN_REAL>val
            success = EIP_write_tag(self._conn, parsed_tag, T_CIP_REAL, 1, <CN_USINT*>&real_buffer, NULL, NULL)
        elif dtype == "sint":
            sint_buffer = <CN_SINT>val
            success = EIP_write_tag(self._conn, parsed_tag, T_CIP_SINT, 1, <CN_USINT*>&sint_buffer, NULL, NULL)
        elif dtype == "int":
            int_buffer = <CN_INT>val
            success = EIP_write_tag(self._conn, parsed_tag, T_CIP_INT, 1, <CN_USINT*>&int_buffer, NULL, NULL)
        elif dtype == "dint":
            dint_buffer = <CN_DINT>val
            success = EIP_write_tag(self._conn, parsed_tag, T_CIP_DINT, 1, <CN_USINT*>&dint_buffer, NULL, NULL)

        EIP_free_ParsedTag(parsed_tag)
        if not success:
            raise RuntimeError("did not write " + tag)

    def read_tag(self, tag, dtype, elements=1):
        global MAX_STRING_SIZE
        cdef char* string_result

        if dtype not in ["sint", "int", "dint", "real", "string"]:
            raise ValueError("unsupported type: " + dtype)

        if not isinstance(tag, unicode):
            raise ValueError("tag must be of type unicode")

        cdef bytes btag = tag.encode("utf-8")
        cdef ParsedTag* parsed_tag = EIP_parse_tag(btag)
        if parsed_tag is NULL:
            raise RuntimeError("Failed to parse the tag " + tag)

        cdef size_t data_len, request_size, response_size
        cdef const CN_USINT *data = EIP_read_tag(self._conn,
                                                 parsed_tag,
                                                 elements,
                                                 &data_len,
                                                 &request_size,
                                                 &response_size)
        if data is NULL:
            raise RuntimeError("could not get data")
        if DEBUG:
            dump_raw_CIP_data(data, elements)

        try:
            # cast all int types to standard pyhton int i.e. long
            if dtype in ["sint", "int", "dint"]:
                return self._get_cip_dint(data, 0)
            elif dtype == "real":
                return self._get_cip_double(data, 0)
            elif dtype == "string":
                string_result = <char*>malloc(MAX_STRING_SIZE*sizeof(char))
                if string_result is NULL:
                    raise MemoryError("memory allocation failed for string_result")
                success = get_CIP_STRING(data, string_result, MAX_STRING_SIZE)
                if not success:
                    raise RuntimeError("could not get string from data")
                pystring_result = (<bytes>string_result).decode() # make python copy of string_result
                free(string_result)
                return pystring_result
            else:
                raise RuntimeError("illegal state: dtype not supported")
        finally:
            EIP_free_ParsedTag(parsed_tag)

        
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