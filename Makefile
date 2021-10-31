SOURCE_DIR=src
BUILD=build
MAIN=$(SOURCE_DIR)/main.rkt
EXE=sfl

all: test sfl

docker:
	docker build -t sufflain-server .

distribute: test sfl
	raco distribute dist $(BUILD)/$(EXE)

sfl: $(BUILD) $(MAIN)
	raco exe -o $(BUILD)/$(EXE) $(MAIN)

$(BUILD):
	mkdir $@

test:
	raco test $(SOURCE_DIR)

clean:
	if [ -d "$(BUILD)" ]; then\
	 rm -r $(BUILD) ; \
	fi