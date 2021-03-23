import os
import sys
from setuptools import find_packages
from setuptools_dso import Extension, setup, cythonize

import epicscorelibs.version
from epicscorelibs.path import include_path
from epicscorelibs.config import get_config_var

# Place the directory containing _version_git on the path
for path, _, filenames in os.walk(os.path.dirname(os.path.abspath(__file__))):
    if "_version_git.py" in filenames:
        sys.path.append(path)
        break

from _version_git import __version__, get_cmdclass  # noqa


def build_extention(extention_name, sources):
    ext =  Extension(
        name = extention_name,
        sources = 
        [
            "src/ether_ip/ether_ip.c",
        ] + sources,
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
    )
    return ext

extentions = [
        build_extention(
            extention_name="pyether_ip.eip_driver",
            sources = ["src/pyether_ip/eip_driver.pyx"]
        ),
]

setup(
    ext_modules = cythonize(extentions),

    name="pyether_ip",
    cmdclass=get_cmdclass(),
    version=__version__,
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
