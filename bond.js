// Generated by CoffeeScript 1.3.3
(function() {
  var allStubs, arrayEqual, bond, createAnonymousSpy, createReturnSpy, createThroughSpy, enhanceSpy, nextTick, registerCleanupHook,
    __slice = [].slice;

  createThroughSpy = function(getValue, bondApi) {
    var spy;
    spy = function() {
      var args, isConstructor, result;
      args = Array.prototype.slice.call(arguments);
      spy.calledArgs[spy.called] = args;
      spy.called++;
      result = getValue.apply(this, args);
      isConstructor = this instanceof arguments.callee;
      if (isConstructor) {
        return this;
      }
      return result;
    };
    return enhanceSpy(spy, getValue, bondApi);
  };

  createReturnSpy = function(getValue, bondApi) {
    var spy;
    spy = function() {
      var args;
      args = Array.prototype.slice.call(arguments);
      spy.calledArgs[spy.called] = args;
      spy.called++;
      return getValue.apply(this, args);
    };
    return enhanceSpy(spy, getValue, bondApi);
  };

  createAnonymousSpy = function() {
    var returnValue, spy;
    returnValue = null;
    spy = function() {
      var args;
      args = Array.prototype.slice.call(arguments);
      spy.calledArgs[spy.called] = args;
      spy.called++;
      return returnValue;
    };
    enhanceSpy(spy);
    spy["return"] = function(newReturnValue) {
      returnValue = newReturnValue;
      return spy;
    };
    return spy;
  };

  enhanceSpy = function(spy, original, bondApi) {
    var k, v;
    spy.prototype = original != null ? original.prototype : void 0;
    spy.called = 0;
    spy.calledArgs = [];
    spy.calledWith = function() {
      var args, lastArgs;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (!spy.called) {
        return false;
      }
      lastArgs = spy.calledArgs[spy.called - 1];
      return arrayEqual(args, lastArgs);
    };
    if (bondApi) {
      for (k in bondApi) {
        v = bondApi[k];
        spy[k] = v;
      }
    }
    return spy;
  };

  arrayEqual = function(A, B) {
    var a, b, i, _i, _len;
    for (i = _i = 0, _len = A.length; _i < _len; i = ++_i) {
      a = A[i];
      b = B[i];
      if (a !== b) {
        return false;
      }
    }
    return true;
  };

  nextTick = (function() {
    if (typeof (typeof process !== "undefined" && process !== null ? process.nextTick : void 0) === 'function') {
      return process.nextTick;
    }
    if (typeof setImmediate === 'function') {
      return setImmediate;
    }
    return function(fn) {
      return setTimeout(fn, 0);
    };
  })();

  allStubs = [];

  registerCleanupHook = function() {
    var after, _ref, _ref1;
    after = (_ref = (_ref1 = typeof afterEach !== "undefined" && afterEach !== null ? afterEach : testDone) != null ? _ref1 : this.cleanup) != null ? _ref : function() {
      throw new Error('bond.cleanup must be specified if your test runner does not use afterEach or testDone');
    };
    return after(function() {
      var stubRestore, _i, _len;
      for (_i = 0, _len = allStubs.length; _i < _len; _i++) {
        stubRestore = allStubs[_i];
        stubRestore();
      }
      return allStubs = [];
    });
  };

  registerCleanupHook();

  bond = function(obj, property) {
    var asyncReturn, previous, registerRestore, restore, returnMethod, through, to;
    if (arguments.length === 0) {
      return createAnonymousSpy();
    }
    previous = obj[property];
    if (!(previous != null)) {
      throw new Error("Could not find property " + property + ".");
    }
    registerRestore = function() {
      return allStubs.push(restore);
    };
    restore = function() {
      return obj[property] = previous;
    };
    to = function(newValue) {
      registerRestore();
      obj[property] = newValue;
      return obj[property];
    };
    returnMethod = function(returnValue) {
      var returnValueFn;
      registerRestore();
      returnValueFn = function() {
        return returnValue;
      };
      obj[property] = createReturnSpy(returnValueFn, this);
      return obj[property];
    };
    asyncReturn = function() {
      var returnValues;
      returnValues = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return to(function() {
        var args, callback, _i;
        args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
        if (typeof callback !== 'function') {
          throw new Error('asyncReturn expects last argument to be a function');
        }
        return nextTick(function() {
          return callback.apply(null, returnValues);
        });
      });
    };
    through = function() {
      obj[property] = createThroughSpy(previous, this);
      return obj[property];
    };
    return {
      'to': to,
      'return': returnMethod,
      'asyncReturn': asyncReturn,
      'through': through,
      'restore': restore
    };
  };

  bond.version = '0.0.11';

  if (typeof window !== "undefined" && window !== null) {
    window.bond = bond;
  }

  if (typeof module !== "undefined" && module !== null) {
    module.exports = bond;
  }

}).call(this);
