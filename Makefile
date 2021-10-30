SOURCE_DIR=src
BUILD=build
MAIN=$(SOURCE_DIR)/main.rkt

all: test sfl

docker:
	docker build -t sufflain-server .

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