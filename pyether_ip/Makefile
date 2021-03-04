TOP = ..

install: build

build: copy_eip_source test
	pip wheel . -w wheels
	# pipenv run python setup.py sdist bdist_wheel

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
	rm src/pyether_ip/*.c
	rm src/pyether_ip/*.so

