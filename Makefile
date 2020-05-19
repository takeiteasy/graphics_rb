OUT=build/
TARGET=$(OUT)graphics
SRC=graphics/graphics/graphics
CC=clang
OPTS=-x objective-c -fno-objc-arc
DEPS=-framework Cocoa

all: $(TARGET).dylib clean

$(TARGET).dylib: $(TARGET).o
	$(CC) -shared -fpic -o $@ $^ $(DEPS)

$(TARGET).o: $(SRC).c $(TARGET).h $(TARGET).rb
	$(CC) $(OPTS) -c -o $@ $<

$(TARGET).rb: $(TARGET).h
	ruby generate_bindings.rb > $@

$(TARGET).h: $(SRC).h $(OUT)
	$(CC) -E $< > $@

$(OUT):
	mkdir $@

.PHONY: deepclean clean
deepclean:
	rm -f $(TARGET).h $(TARGET).dylib $(TARGET).o $(TARGET).rb
clean:
	rm -f $(TARGET).h $(TARGET).o
