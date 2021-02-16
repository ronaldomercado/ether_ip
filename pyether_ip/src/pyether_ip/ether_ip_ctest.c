/* $Id$
 *
 * EtherNet/IP: ControlNet over Ethernet
 *
 * Test functionality for hosts to be called from C/Python
 *
 * tim.guite@diamond.ac.uk
 */

#include <memory.h>
#include <stdio.h>
#include <string.h>
#include <stddef.h>
#include <time.h>

#include "ether_ip.h"
#include "ether_ip_ctest.h"

#define MAX_STRING_SIZE 40

unsigned char *test_read_tag(const char *input_tag, const char *input_ip)
{
    EIPConnection *c = EIP_init();
    const char *ip = input_ip;
    unsigned short port = 0xAF12;
    int slot = 0;
    size_t timeout_ms = 5000;
    size_t elements = 1;
    ParsedTag *tag = 0;
    const char *arg;
    size_t i;
    CN_REAL writeval;
    eip_bool write = false;
    size_t test_runs = 1;

    struct timeval now;
    double start, end, duration;

    EIP_verbosity = 5;

    tag = EIP_parse_tag(input_tag);

    char buffer[EIP_MAX_TAG_LENGTH];
    EIP_copy_ParsedTag(buffer, tag);
    EIP_printf(3, "Tag '%s'\n", buffer);

    const CN_USINT *data = 0;
    if (EIP_startup(c, ip, port, slot, timeout_ms) && tag)
    {
        size_t data_len;
        data = EIP_read_tag(c, tag, elements, &data_len, 0, 0);
        if (data)
            dump_raw_CIP_data(data, elements);
    }
    EIP_shutdown(c);
    EIP_dispose(c);
    EIP_free_ParsedTag (tag);
    tag = 0;

    return data;
}


int read_int_from_tag(const char *input_tag, const char *input_ip, int* result)
{
    unsigned char *data = test_read_tag(input_tag, input_ip);
    int err = get_CIP_DINT(data, 0, result);
    return err;
}

int read_double_from_tag(const char *input_tag, const char *input_ip, double* result)
{
    unsigned char *data = test_read_tag(input_tag, input_ip);
    int err = get_CIP_double(data, 0, result);
    return err;
}

int read_string_from_tag(const char *input_tag, const char *input_ip, char* buffer, size_t size)
{
    unsigned char *data = test_read_tag(input_tag, input_ip);
    int err = get_CIP_STRING(data, buffer, size);
    return err;
}

int main()
{
    int err;
    printf(">>>INT/BOOL<<<\n");
    int result;

    err = read_int_from_tag("PLC_Interface[23].Num", "172.23.243.77", &result);
    printf("err = %d\n", err);
    printf("%d\n", result);

    err = read_int_from_tag("_EIP2_TDLinkCfgErr", "172.23.243.77", &result);
    printf("err = %d\n", err);
    printf("%d\n", result);

    err = read_int_from_tag("_EIP2_TDLinkCfgErr", "172.23.243.77", &result);
    printf("err = %d\n", err);
    printf("%d\n", result);

    printf(">>>DOUBLE<<<\n");
    double dresult;

    err = read_double_from_tag("V[1].User_Set_Position", "172.23.243.77", &dresult);
    printf("err = %d\n", err);
    printf("%lf\n", dresult);

    printf(">>>STRING<<<\n");
    // char* buffer = malloc(MAX_STRING_SIZE*sizeof(char));
    // memcpy(buffer, "empty\n", 6);
    char buffer[MAX_STRING_SIZE] = "empty";
    printf(">>>%s\n", buffer);
    err = read_string_from_tag("V[1].Interface_Desc0", "172.23.243.77", buffer, MAX_STRING_SIZE);
    printf("err = %d\n", err);
    printf(">>>%s\n", buffer);

    printf("DONE\n");
    printf("----\n");
    

    return 0;
}