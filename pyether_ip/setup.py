from setuptools import setup, find_packages
from distutils.extension import Extension
from Cython.Build import cythonize

import epicscorelibs.version
from epicscorelibs.path import include_path, lib_path
print(lib_path)

extentions = [
    Extension(
        name="client",
        sources = 
        [
            "src/pyether_ip/client.pyx",
            "src/pyether_ip/ether_ip_ctest.c",
            "src/pyether_ip/ether_ip.c",
        ],
        include_dirs = [include_path],
        library_dirs = [lib_path],
        libraries = ["Com"], #ether_ip.c dependency
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
           "-Wl,-rpath," + lib_path,
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
        "cython",
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
    options={"bdist_wheel": {"universal": "1"}},
)
