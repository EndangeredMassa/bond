{ equal, deepEqual } = window?.assertive or require 'assertive'

isFunction = (obj) ->
  typeof obj == 'function'

createThroughSpy = (getValue, bondApi) ->
  spy = ->
    args = Array::slice.call(arguments)
    spy.calledArgs[spy.called] = args
    spy.called++

    result = getValue.apply(this, args)

    isConstructor = (this instanceof arguments.callee)
    return this if isConstructor and typeof result != 'object'
    result

  enhanceSpy(spy, getValue, bondApi)

createReturnSpy = (getValue, bondApi) ->
  spy = ->
    args = Array::slice.call(arguments)
    spy.calledArgs[spy.called] = args
    spy.called++

    getValue.apply(this, args)

  enhanceSpy(spy, getValue, bondApi)

createAnonymousSpy = ->
  returnValue = null

  spy = ->
    args = Array::slice.call(arguments)
    spy.calledArgs[spy.called] = args
    spy.called++

    returnValue

  enhanceSpy(spy)

  spy.return = (newReturnValue) ->
    returnValue = newReturnValue
    spy
  spy

enhanceSpy = (spy, original, bondApi) ->
  spy.prototype = original?.prototype
  spy.called = 0
  spy.calledArgs = []
  spy.calledWith = (args...) ->
    return false if !spy.called
    lastArgs = spy.calledArgs[spy.called-1]
    arrayEqual(args, lastArgs)

  spy[k] = v for k, v of bondApi if bondApi

  spy

arrayEqual = (A, B) ->
  for a, i in A
    b = B[i]
    return false if a != b

  true


nextTick = do ->
  return process.nextTick if isFunction(process?.nextTick)
  return setImmediate if setImmediate? && isFunction(setImmediate)

  (fn) ->
    setTimeout(fn, 0)





_registry = []
_find = (obj) ->
  for store in _registry
    if store.obj == obj
      return store

  store =
    obj: obj
    props: {}
  _registry.push(store)
  store

registry =
  set: (obj, prop, value, newValue) ->
    store = _find(obj)
    # ignore if it looks like we're
    # bonding multiple times
    if !store.props[prop]?
      store.props[prop] = value

  get: (obj, prop) ->
    _find(obj).props[prop]

  restore: (obj, prop) ->
    obj[prop] = _find(obj).props[prop]

  restoreAll: ->
    for store in _registry
      for prop, value of store.props
        store.obj[prop] = value

    _registry = []



allStubs = []
registered = false
registerCleanupHook = ->
  return if registered

  after = afterEach ? testDone ? QUnit?.testDone ? bond.cleanup ? ->
    throw new Error('bond.cleanup must be specified if your test runner does not use afterEach or testDone')

  after ->
    registry.restoreAll()

  registered = true

bond = (obj, property) ->
  registerCleanupHook()
  return createAnonymousSpy() if arguments.length == 0

  previous = obj[property]

  registerRestore = ->
    registry.set obj, property, previous

  restore = ->
    registry.restore(obj, property)

  to = (newValue) ->
    registerRestore()

    if isFunction(newValue)
      newValue = createThroughSpy(newValue, this)

    obj[property] = newValue
    obj[property]

  returnMethod = (returnValue) ->
    registerRestore()
    returnValueFn = -> returnValue
    obj[property] = createReturnSpy(returnValueFn, this)
    obj[property]

  asyncReturn = (returnValues...) ->
    to (args..., callback) ->
      if !isFunction(callback)
        throw new Error('asyncReturn expects last argument to be a function')

      nextTick ->
        callback(returnValues...)

  through = ->
    registerRestore()
    obj[property] = createThroughSpy(previous, this)
    obj[property]

  {
    'to': to
    'return': returnMethod
    'asyncReturn': asyncReturn
    'through': through
    'restore': restore
  }

bond.bond = bond # to allow {bond, calledOnceWithArgs} = require 'bondjs'

# strong call assertions, with assertive-style clear output:
#   calledOnceWithArgs 'done', done, null, view
# ...testing both the arg signature and that it's called only once
# without forcing tests to know about bond's implementation details
bond.calledOnceWithArgs = (name, bondFn, args...) ->
  equal "calls to #{name}", 1, bondFn.called
  deepEqual "#{name} args", args, bondFn.calledArgs[0]

bond.calledNTimesWithArgs = (n, name, bondFn, argLists...) ->
  if typeof n is 'number'
    equal "calls to #{name}", n, bondFn.called
  else if n?
    [name, bondFn, argLists...] = arguments
  for args, n in argLists
    if args?
      deepEqual "#{name} args, call number #{n+1}", args, bondFn.calledArgs[n]

window.bond = bond if window?
module.exports = bond if module?.exports
