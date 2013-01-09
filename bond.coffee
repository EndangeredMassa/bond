createThroughSpy = (getValue, bondApi) ->
  spy = ->
    args = Array::slice.call(arguments)
    spy.calledArgs[spy.called] = args
    spy.called++

    isConstructor = Object.keys(this).length == 0

    result = getValue.apply(this, args)

    return this if isConstructor
    result

  enhanceSpy(spy, getValue, bondApi)

createReturnSpy = (getValue, bondApi) ->
  spy = ->
    args = Array::slice.call(arguments)
    spy.calledArgs[spy.called] = args
    spy.called++

    getValue.apply(this, args)

  enhanceSpy(spy, getValue, bondApi)

enhanceSpy = (spy, original, bondApi) ->
  spy.prototype = original.prototype
  spy.called = 0
  spy.calledArgs = []
  spy.calledWith = (args...) ->
    return false if !spy.called
    lastArgs = spy.calledArgs[spy.called-1]
    arrayEqual(args, lastArgs)
  spy[k] = v for k, v of bondApi
  spy

arrayEqual = (A, B) ->
  for a, i in A
    b = B[i]
    return false if a != b

  true

registeredHooks = false
allStubs = []
registerHooks = ->
  return if registeredHooks

  afterEach ->
    for stubRestore in allStubs
      stubRestore()
    allStubs = []

bond = (obj, property) ->
  return createReturnSpy(->) if arguments.length == 0

  registerHooks()
  previous = obj[property]

  if !previous?
    throw new Error("Could not find property #{property}.")

  after = afterEach ? testDone ? this.cleanup ? ->
    throw new Error('bond.cleanup must be specified if your test runner does not use afterEach or testDone')

  registerRestore = ->
    allStubs.push restore
  restore = ->
    obj[property] = previous

  to = (newValue) ->
    registerRestore()
    obj[property] = newValue
    obj[property]

  returnMethod = (returnValue) ->
    registerRestore()
    returnValueFn = -> returnValue
    obj[property] = createReturnSpy(returnValueFn, this)
    obj[property]

  through = ->
    obj[property] = createThroughSpy(previous, this)
    obj[property]

  {
    to:       to
    return:   returnMethod
    through:  through
    restore:  restore
  }

bond.version = '0.0.8'

window?.bond = bond
module?.exports = bond
