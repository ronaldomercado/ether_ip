unsigned char *test_read_tag(const char *input_tag, const char *input_ip);

int read_int_from_tag(const char *input_tag, const char *input_ip);
double read_double_from_tag(const char *input_tag, const char *input_ip);
void read_string_from_tag(const char *input_tag, const char *input_ip, char* buffer, size_t size);