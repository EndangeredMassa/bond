BIN=./node_modules/.bin

MOCHA=$(BIN)/mocha
COFFEE=$(BIN)/coffee

compile:
	$(COFFEE) --js <bond.coffee >lib/bond.js

.PHONY: test

test:	compile
	$(MOCHA) --compilers coffee:coffee-script-redux/register --reporter spec --colors test.coffee
