cdef extern from "<ether_ip.h>":
    int EIP_verbosity

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
        T_CIP_STRING = 0x00D0

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
from cpython cimport array
import array

from libc.stdio cimport printf
from libc.stdlib cimport malloc, free
from libc.string cimport strcpy, strlen, memcpy

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
    
cdef class Tag:
    cdef EIPDriver _drv
    def __cinit__(self, tag, dtype, drv, elements=1):
        self._tag = tag
        self._dtype = dtype
        self._drv = drv
        self._elements = elements

@cython.final # prevent subclassing
cdef class EIPDriver:
    cdef EIPConnection* _conn
    cdef char* _ip # needs to stay alive until class instance is cleaned up
    cdef bint _started
    cdef bint _debug

    def __cinit__(self, ip, port=0xAF12, slot=0, timeout_ms=5000, level=4):

        self._debug = False
        self._started = False
        self._ip = NULL
        self._conn = NULL

        global EIP_verbosity
        EIP_verbosity = level
        if level >= 5:
            self._debug = True

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


    def set_verbosity(self, level):
        global EIP_verbosity
        EIP_verbosity = level
        if level >= 5:
            self._debug = True

    def write(self, tag, val, dtype, elements=1):
        if dtype not in ["string", "word", "dword", "bool", "sint", "int", "dint", "real"]:
            raise ValueError("unsupported type: " + dtype)

        if dtype == "string" and elements != 1:
            raise ValueError("reading string arrays is not supported")
        
        if elements != 1:
            if not isinstance(val, list) or len(val) != elements:
                raise ValueError("if param 'elements' > 1, input must be list with len(list) == 'elements'")
        else:
            if isinstance(val, list):
                raise ValueError("a list was provided as value while param 'elements' == 1")

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

        cdef array.array array_buffer
        cdef CN_REAL[:] real_array_buffer
        cdef CN_SINT[:] sint_array_buffer
        cdef CN_INT[:] int_array_buffer
        cdef CN_DINT[:] dint_array_buffer

        success = False
        if dtype == "real":
            if elements <= 1:
                real_buffer = <CN_REAL>val
                success = EIP_write_tag(self._conn,
                                        parsed_tag,
                                        T_CIP_REAL,
                                        elements,
                                        <CN_USINT*>&real_buffer,
                                        NULL, NULL)
            else:
                array_buffer = array.array("f", val)
                real_array_buffer = array_buffer
                success = EIP_write_tag(self._conn,
                                        parsed_tag,
                                        T_CIP_REAL,
                                        elements,
                                        <CN_USINT*>&real_array_buffer[0],
                                        NULL, NULL)
        elif dtype == "bool":
            if elements <= 1:
                bool_buffer = b"\x01\x00" if <bint>val else b"\x00\x00"
                success = EIP_write_tag(self._conn,
                                        parsed_tag,
                                        T_CIP_BOOL,
                                        elements,
                                        <CN_USINT*>bool_buffer,
                                        NULL, NULL)
            else:
                translate_bool = lambda b: b"\x01" if <bint>b else b"\x00"
                bool_buffer = b"".join([translate_bool(b) for b in val])
                success = EIP_write_tag(self._conn,
                                        parsed_tag,
                                        T_CIP_BOOL,
                                        elements,
                                        <CN_USINT*>bool_buffer,
                                        NULL, NULL)
        elif dtype == "sint":
            if elements <= 1:
                sint_buffer = <CN_SINT>val
                success = EIP_write_tag(self._conn,
                                        parsed_tag,
                                        T_CIP_SINT,
                                        elements,
                                        <CN_USINT*>&sint_buffer,
                                        NULL, NULL)
            else:
                array_buffer = array.array("b", val)
                sint_array_buffer = array_buffer
                success = EIP_write_tag(self._conn,
                                        parsed_tag,
                                        T_CIP_SINT,
                                        elements,
                                        <CN_USINT*>&sint_array_buffer[0],
                                        NULL, NULL)
        elif dtype == "int":
            if elements <= 1:
                int_buffer = <CN_INT>val
                success = EIP_write_tag(self._conn,
                                        parsed_tag,
                                        T_CIP_INT,
                                        elements,
                                        <CN_USINT*>&int_buffer,
                                        NULL, NULL)
            else:
                array_buffer = array.array("h", val)
                int_array_buffer = array_buffer
                success = EIP_write_tag(self._conn,
                                        parsed_tag,
                                        T_CIP_INT,
                                        elements,
                                        <CN_USINT*>&int_array_buffer[0],
                                        NULL, NULL)
        elif dtype == "dint":
            if elements <=1:
                dint_buffer = <CN_DINT>val
                success = EIP_write_tag(self._conn,
                                        parsed_tag,
                                        T_CIP_DINT,
                                        elements,
                                        <CN_USINT*>&dint_buffer,
                                        NULL, NULL)
            else:
                array_buffer = array.array("i", val)
                dint_array_buffer = array_buffer
                success = EIP_write_tag(self._conn,
                                        parsed_tag,
                                        T_CIP_DINT,
                                        elements,
                                        <CN_USINT*>&dint_array_buffer[0],
                                        NULL, NULL)
        elif dtype in ["word", "dword"]:
            word_type = T_CIP_WORD if dtype == "word" else T_CIP_BITS
            word_n_bytes = 2 if dtype == "word" else 4
            if elements <=1:
                if not isinstance(val, bytes):
                    raise ValueError("value written to a WORD tag must be of type 'bytes'")
                if len(val) != word_n_bytes:
                    raise ValueError("byte string provided is larger than word buffer")
                success = EIP_write_tag(self._conn,
                                        parsed_tag,
                                        word_type,
                                        elements,
                                        <CN_USINT*>val,
                                        NULL, NULL)
            else:
                for word in val:
                    if not isinstance(word, bytes):
                        raise ValueError("value written to a WORD tag must be of type 'bytes'")
                    if len(word) != word_n_bytes:
                        raise ValueError("byte string provided is larger than word buffer")
                word_buffer = b"".join(val)
                success = EIP_write_tag(self._conn,
                                        parsed_tag,
                                        word_type,
                                        elements,
                                        <CN_USINT*>word_buffer,
                                        NULL, NULL)
        elif dtype == "string":
            if len(val) > MAX_STRING_SIZE or not isinstance(val, bytes):
                raise ValueError("string must be of type 'bytes' and no larger than %d chars" % MAX_STRING_SIZE)
            success = EIP_write_tag(self._conn,
                                    parsed_tag,
                                    T_CIP_STRING,
                                    len(val),
                                    <CN_USINT*>val,
                                    NULL, NULL)
        else:
            raise ValueError("ILLIGAL STATE: dtype not found.")

        EIP_free_ParsedTag(parsed_tag)
        if not success:
            raise RuntimeError("EIPDriver.write method failed to write %s to %s with dtype '%s'"\
                               % (str(val), tag, dtype))


    def read(self, tag, dtype, elements=1):
        global MAX_STRING_SIZE
        cdef char* string_result
        cdef unsigned int word_result

        if dtype not in ["bool", "word", "dword", "sint", "int", "dint", "real", "string"]:
            raise ValueError("unsupported type: " + dtype)

        if dtype == "string" and elements != 1:
            raise ValueError("reading string arrays is not supported")

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
        EIP_free_ParsedTag(parsed_tag)
        if data is NULL:
            raise RuntimeError("could not get data")

        if self._debug:
            dump_raw_CIP_data(data, elements)

        # cast all int types to standard pyhton int i.e. long
        if dtype in ["bool", "sint", "int", "dint"]:
            if elements <= 1:
                return self._get_cip_dint(data, 0)
            else:
                return [self._get_cip_dint(data, i) for i in range(elements)]
        elif dtype == "real":
            if elements <= 1:
                return self._get_cip_double(data, 0)
            else:
                return [self._get_cip_double(data, i) for i in range(elements)]
        elif dtype in ["word", "dword"]:
            # https://stackoverflow.com/questions/58584639/how-to-convert-a-c-binary-buffer-to-it-s-hex-representation-in-python-string
            n_bytes = 2 if dtype == "word" else 4
            if elements <= 1:
                self._get_cip_word(data, 0, &word_result)
                return (<char*>&word_result)[:n_bytes]
            else:
                word_list = []
                for i in range(elements):
                    self._get_cip_word(data, i, &word_result)
                    word_list.append((<char*>&word_result)[:n_bytes])
                return word_list

        elif dtype == "string":
            string_result = <char*>malloc(MAX_STRING_SIZE*sizeof(char))
            if string_result is NULL:
                raise MemoryError("memory allocation failed for string_result")
            success = get_CIP_STRING(data, string_result, MAX_STRING_SIZE)
            if not success:
                raise RuntimeError("could not get string from data")
            pystring_result = <bytes>string_result # make python copy of string_result
            free(string_result)
            return pystring_result
        else:
            raise RuntimeError("ILLEGAL STATE: dtype '%s' not found".format(dtype))

        
    cdef bint _get_cip_word(self,
                           const CN_USINT *raw_type_and_data,
                           size_t element,
                           unsigned int *result_buf
                           ):
        success = get_CIP_UDINT(raw_type_and_data, element, result_buf)
        if not success:
            raise RuntimeError("could not get word from data")
        return success

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