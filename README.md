# bond

_the simple stub/spy javascript library_

bond only provides stubbing and spy functionality.
For test running and assertions,
you will need to use other libraries.

This project is a safe and inclusive place
for contributors of all kinds.
See the [Code of Conduct](CODE_OF_CONDUCT.md)
for details.


## bond api

`bond(object, 'propertyOrMethodName')` returns the bond api

`bond()` returns an anonymous spy

`bond().return(value)` returns an anonymous spy that returns the given value when called

`bond#to(value)` replaces the value with a new value; reverts the stub after the current test completes

`bond#return(value)` replaces the value with a spy that returns the given value; reverts the spy after the current test completes

`bond#asyncReturn(values...)` replaces the value with a spy that calls the last argument passed to the function with the provided values

`bond#through()` replaces the value with a spy, but allows it to return its normal value

`bond#restore()` replaces a spy/stub with its original value; useful for implementing your own `cleanup` handler (see below)

### bond spies

`spy.called` is a call count for the spy

`spy.calledWith(arg1, arg2, ...)` is a test for being called with specific values

`spy.calledArgs` is an array of methods calls, each index holds the array of arguments for that call

## usage

`npm install bondjs` -> `bond = require 'bondjs'`

**with mocha, qunit, jasmine**: These frameworks should work with bond as is. Bond looks for a global function named either `afterEach` or `testDone` to implement its spy/stub restore functionality. If those exist, as they should when using these frameworks, it should work fine.

**with some other test runner**: You may need to implement your own `cleanup` method for bond to work properly. This might look like the following.

`bond.cleanup = someTestRunner.registerAfterCallback`

## tests

see the `test.coffee` file for examples

use `npm test` to run the tests

## license

[MIT](LICENSE)

