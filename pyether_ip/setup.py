from setuptools import find_packages
from setuptools_dso import Extension, setup, cythonize

import epicscorelibs.version
from epicscorelibs.path import include_path
from epicscorelibs.config import get_config_var

extentions = [
    Extension(
        name="pyether_ip.eip_client",
        sources = 
        [
            "src/pyether_ip/eip_client.pyx",
            "src/pyether_ip/ether_ip_ctest.c",
            "src/ether_ip/ether_ip.c",
        ],
        include_dirs = [include_path, "src/ether_ip"],
        dsos = ["epicscorelibs.lib.Com"],
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
