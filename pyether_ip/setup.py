from setuptools import setup
from distutils.extension import Extension
from Cython.Build import cythonize

extentions = [
    Extension(
        name="ether_ip",
        sources = 
        [
            "src/pyether_ip/ether_ip.pyx",
            "src/pyether_ip/ether_ip_ctest.c",
            "../ether_ipApp/src/ether_ip.c",
        ],
        libraries = ["Com"], #ether_ip.c dependency
        library_dirs = ["/dls_sw/epics/R3.14.12.7/base/lib/linux-x86_64"],
        include_dirs = [
            "../include", #include <ether_ip.h>
            "/dls_sw/epics/R3.14.12.7/base/include",
            "/dls_sw/epics/R3.14.12.7/base/include/os/Linux",
        ],
        extra_compile_args = [
           "-g",
           "-Wall",
           "-Wno-unused-value",
           "-m64",
        ],
        extra_link_args = [
           "-D_GNU_SOURCE",
           "-D_DEFAULT_SOURCE",
           "-D_X86_64_",
           "-DUNIX",
           "-Dlinux",
           "-Wl,-rpath,/dls_sw/epics/R3.14.12.7/base/lib/linux-x86_64",
        ]
    ),
]

setup(
    ext_modules = cythonize(extentions)
)
