TOP = ..

install: build

build: copy_eip_source
	# pip wheel . -w wheels
	pip install .
	python setup.py build


test2: clean copy_eip_source
	python setup.py sdist
	pip install dist/pyether_ip-0.0.1a1.tar.gz
	python -c 'from pyether_ip.eip_driver import EIPDriver;drv = EIPDriver("172.23.243.78", level=10);a = drv.write("STRING39_Test", b"hello", dtype="string")'


copy_eip_source:
	mkdir -p src/ether_ip
	/bin/cp ../ether_ipApp/src/ether_ip.c src/ether_ip/ether_ip.c
	/bin/cp ../ether_ipApp/src/ether_ip.h src/ether_ip/ether_ip.h
	/bin/cp ../ether_ipApp/src/eip_bool.h src/ether_ip/eip_bool.h

test: copy_eip_source
	pipenv run tox

clean:
	rm --force --recursive build/
	rm --force --recursive dist/
	rm --force --recursive *.egg-info

