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
    for calledArgs in spy.calledArgs
      return true if arrayEqual(args, calledArgs)
    false

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

window.bond = bond if window?
module.exports = bond if module?.exports
