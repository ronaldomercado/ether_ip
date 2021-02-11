gcc -D_GNU_SOURCE -D_DEFAULT_SOURCE -D_X86_64_  -DUNIX  -Dlinux\
    -g -Wall -Wno-unused-value -m64\
    -I/dls_sw/epics/R3.14.12.7/base/include/os/Linux\
    -I/dls_sw/epics/R3.14.12.7/base/include\
    -I../../../ether_ipApp/src\
    -L/dls_sw/epics/R3.14.12.7/base/lib/linux-x86_64\
    -lCom -Wl,-rpath,/dls_sw/epics/R3.14.12.7/base/lib/linux-x86_64\
    ether_ip_ctest.c\
    ../../../ether_ipApp/src/ether_ip.c\
    && ./a.out && rm a.out

