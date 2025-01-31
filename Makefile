CC      ?= cc
CP      ?= cp -f
RM      ?= rm -f
MKDIR   ?= mkdir -p
INSTALL ?= install

PREFIX  ?= /usr/local

CFLAGS += -Wall -std=c99 -pedantic  -g2 -Og

.PHONY: all
all: test

.PHONY: readme_update
readme_update:
	# Library Version (From clib package metadata)
	jq -r '.version' clib.json | xargs -I{} sed -i 's|<version>.*</version>|<version>{}</version>|' README.md
	jq -r '.version' clib.json | xargs -I{} sed -i 's|<versionBadge>.*</versionBadge>|<versionBadge>![Version {}](https://img.shields.io/badge/version-{}-blue.svg)</versionBadge>|' README.md

.PHONY: test
test: test.c kv_parse_value.c kv_file_parse_value.c
	@echo "# MINIMUM"
	@$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@
	@./test
	@$(RM) test

	@echo "# KV_PARSE_QUOTED_STRINGS"
	@$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@ -DKV_PARSE_QUOTED_STRINGS
	@./test
	@$(RM) test

	@echo "# KV_PARSE_WHITESPACE_SKIP"
	@$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@ -DKV_PARSE_WHITESPACE_SKIP
	@./test
	@$(RM) test

	@echo "# ALL"
	@$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@ -DKV_PARSE_WHITESPACE_SKIP -DKV_PARSE_QUOTED_STRINGS
	@./test
	@$(RM) test

.PHONY: format
format:
	# pip install clang-format
	clang-format -i *.c
	clang-format -i *.h

.PHONY: clean
clean:
	$(RM) *.o *.so *.aarch64.elf 
	$(RM) test
