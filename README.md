# bond: the simple stub/spy javascript library

bond only provides stubbing and spy functionality. For test running and assertions, you will need to use other libraries.

## bond api

`bond(object, 'propertyOrMethodName')` returns the bond api

`bond()` returns an anonymous spy

`bond().return(value)` returns an anonymous spy that returns the given value when called

`bond#to(value)` replaces the value with a new value; reverts the stub after the current test completes

`bond#return(value)` replaces the value with a spy that returns the given value; reverts the spy after the current test completes

`bond#asyncReturn(values...)` replaces the value with a spy that calls the last argument passed to the function with the provided values

`bond#through()` replaces the value with a spy, but allows it to return its normal value

`bond#restore()` replaces a spy/stub with its original value; useful for implementing your own `cleanup` handler (see below)

## bond spies

`spy.called` is a call count for the spy

`spy.calledWith(arg1, arg2, ...)` is a test for being called with specific values

`spy.calledArgs` is an array of methods calls, each index holds the array of arguments for that call

## usage

`npm install bondjs` -> `bond = require 'bondjs'`

`<script src="bond.js">` -> `window.bond(...)`

You must also add the equivalent of a global `afterEach` callback that calls `bond.cleanup()`.
This will restore all spies made by bond.

## tests

see the `test.coffee` file for examples

use `make test` to run the tests

## license

MIT

