
REPORTER = dot

build:
	@./node_modules/.bin/coffee -b -o lib src

test: build
	@NODE_ENV=test ./node_modules/.bin/mocha \
		--compilers coffee:coffee-script/register \
		--reporter $(REPORTER)

.PHONY: test
