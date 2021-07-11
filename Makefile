SOURCE_DIR=src
BUILD=build
MAIN=$(SOURCE_DIR)/main.rkt

all: test sfl

sfl: $(BUILD) $(MAIN)
	raco exe -o $(BUILD)/$@ $(MAIN)

$(BUILD):
	mkdir $@

test:
	raco test $(SOURCE_DIR)

clean:
	if [ -d "$(BUILD)" ]; then\
	 rm -r $(BUILD) ; \
	fi