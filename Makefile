SOURCE_DIR=src
BUILD=build
DIST=dist
MAIN=$(SOURCE_DIR)/main.rkt
EXE=sfl

all: test sfl

docker:
	docker build -t sufflain-server .

distribute: test sfl
	raco distribute $(DIST) $(BUILD)/$(EXE)

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

	if [ -d "$(DIST)" ]; then\
	 rm -r $(DIST) ; \
	fi