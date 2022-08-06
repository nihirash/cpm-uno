

../zcpr.bin: zcpr.asm
	zxcc MAC -$< -$$PO
	zxcc MLOAD25 -$@=zcpr.hex
	rm ../zcpr.bin || true
	mv zcpr.bin ../

