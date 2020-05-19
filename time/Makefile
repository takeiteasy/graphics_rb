OUT=../build/
SRC=time
TARGET=$(OUT)$(SRC)
CC=clang
OPTS=
DEPS=

all: $(TARGET).dylib clean

alldirty: $(TARGET).dylib

$(TARGET).dylib: $(TARGET).o
	$(CC) -shared -fpic -o $@ $^ $(DEPS)

$(TARGET).o: $(SRC).c $(SRC).h $(OUT)
	$(CC) $(OPTS) -c -o $@ $<

$(OUT):
	mkdir $@

.PHONY: deepclean clean
deepclean:
	rm -f $(TARGET).dylib $(TARGET).o
clean:
	rm -f $(TARGET).o