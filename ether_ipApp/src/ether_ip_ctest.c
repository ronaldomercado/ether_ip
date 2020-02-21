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
#include "ether_ip_ctest.h"
#include "ether_ip.c"

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
        //if (data)
        //    dump_raw_CIP_data(data, elements);
    }
    EIP_shutdown(c);

    return data;
}

int read_int_from_tag(const char *input_tag, const char *input_ip)
{
    unsigned char *data = test_read_tag(input_tag, input_ip);

    return (data[2] | (data[3] << 8));
}

int main()
{
    printf("%d\n", read_int_from_tag("BL06C_EA_RACK_HUMIDITY2", "10.106.3.99"));

    return 0;
}