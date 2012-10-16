bond: the simple stub/spy javascript library
===

bond only provides stubbing and spy functionality. For test running and assertions, you will need to use other libraries.

the api is simple:

bond api
====

`bond(object, 'propertyOrMethodName')` returns the bond api

`bond#to(value)` replaces the value with a new value

`bond#return(value)` replaces the value with a spy that returns the given value

`bond#through()` replaces the value with a spy, but allows it to return its normal value

bond spies
====

`spy.called` is a call count for the spy

`spy.calledWith(arg1, arg2, ...)` is a test for being called with specific values

`spy.calledArgs` is an array of methods calls, each index holds the array of arguments for that call

usage
===

`npm install bondjs` -> `bond = require 'bondjs'`

`<script src="bond.js">` -> `window.bond(...)`

tests
===

see the `test.coffee` file for examples

use `npm test` to run the tests

