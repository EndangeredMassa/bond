BIN=./node_modules/.bin

MOCHA=$(BIN)/mocha
COFFEE=$(BIN)/coffee

all: compile test
compile:
	$(COFFEE) --js <./bond.coffee >./bond.js

.PHONY: test

test:
	$(MOCHA) --compilers coffee:coffee-script-redux/register --reporter spec --colors test.coffee
