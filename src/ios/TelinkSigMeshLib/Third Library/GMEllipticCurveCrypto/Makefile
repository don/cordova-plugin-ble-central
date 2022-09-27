
test: test.m GMEllipticCurveCrypto+hash.m GMEllipticCurveCrypto+hash.h GMEllipticCurveCrypto.h GMEllipticCurveCrypto.m
	llvm-gcc -Wall test.m GMEllipticCurveCrypto.m GMEllipticCurveCrypto+hash.m -o test -ObjC -framework Foundation -framework Security

run-test: test
	./test

clean:
	rm -f test
