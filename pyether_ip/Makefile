TOP = ..

install: build

build: copy_eip_source
	pip wheel . -w wheels
	# pipenv run python setup.py sdist bdist_wheel


test2: clean copy_eip_source
	python setup.py sdist
	pip install dist/pyether_ip-0.0.1a1.tar.gz
	python -c 'from pyether_ip.eip_driver import EIPDriver;drv = EIPDriver("172.23.243.78", level=10);a = drv.write("STRING39_Test", b"hello", dtype="string")'
	

copy_eip_source:
	rm src/ether_ip/ether_ip.c
	rm src/ether_ip/ether_ip.h
	rm src/ether_ip/eip_bool.h
	cp ../ether_ipApp/src/ether_ip.c src/ether_ip/ether_ip.c
	cp ../ether_ipApp/src/ether_ip.h src/ether_ip/ether_ip.h
	cp ../ether_ipApp/src/eip_bool.h src/ether_ip/eip_bool.h

test: copy_eip_source
	pipenv run tox

clean:
	rm --force --recursive build/
	rm --force --recursive dist/
	rm --force --recursive *.egg-info

