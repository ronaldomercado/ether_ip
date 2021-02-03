from setuptools import setup
from distutils.extension import Extension
from Cython.Build import cythonize

extentions = [
    Extension(
        name="ether_ip",
        sources = 
        [
            "src/pyether_ip/ether_ip.pyx",

        ],
        libraries=["ether_ip_ctest"],
        library_dirs=["../lib/linux-x86_64"],
        # include_dirs=["../lib/linux-x86_64"]
    ),
    Extension(
        name="hello",
        sources=["src/pyether_ip/hello.pyx"],
    ),

]

setup(
    ext_modules = cythonize(extentions)
)
