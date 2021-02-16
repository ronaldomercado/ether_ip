from setuptools import find_packages
from setuptools_dso import Extension, setup, cythonize

# from distutils.extension import Extension
# from Cython.Build import cythonize

import epicscorelibs.version
from epicscorelibs.path import include_path, lib_path
from epicscorelibs.config import get_config_var

extentions = [
    Extension(
        name="eip_client",
        sources = 
        [
            "src/pyether_ip/eip_client.pyx",
            "src/pyether_ip/ether_ip_ctest.c",
            "src/ether_ip/ether_ip.c",
        ],
        include_dirs = [include_path, "src/ether_ip"],
        dsos = ["epicscorelibs.lib.Com"],
        # library_dirs = [lib_path],
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
           # "-Wl,-rpath," + lib_path,
        ]
    ),
]

setup(
    ext_modules = cythonize(extentions),

    name="pyether_ip",
    version="0.0.1a1",
    python_requires=">=3.6",
    package_dir={"": "src"},
    packages=find_packages(where="src"),
    include_package_data=True,
    install_requires=[
        epicscorelibs.version.abi_requires(),
        # "cython",
    ],
    # metadata to display on PyPI
    author="Omar Elamin",
    author_email="omar.elamin@diamond.ac.uk",
    description="EtherNet/IP wrapper for python",
    classifiers=[
        "License :: OSI Approved :: Apache Software License",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
    ],
)
