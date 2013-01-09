createThroughSpy = (getValue, bondApi) ->
  spy = ->
    args = Array::slice.call(arguments)
    spy.calledArgs[spy.called] = args
    spy.called++

    isConstructor = Object.keys(this).length == 0

    result = getValue.apply(this, args)

    # not sure why return value matters with `new` call
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

bond = (obj, property) ->
  return createReturnSpy(->) if arguments.length == 0

  previous = obj[property]

  if !previous?
    throw new Error("Could not find property #{property}.")

  after = afterEach ? testDone ? this.cleanup ? ->
    throw new Error("bond.cleanup must be specified if your test runner does not use afterEach or testDone")

  unregistered = false
  restore = ->
    return if unregistered
    obj[property] = previous
    unregistered = true

  to = (newValue) ->
    after(restore)
    obj[property] = newValue
    obj[property]

  returnMethod = (returnValue) ->
    after(restore)
    returnValueFn = -> returnValue
    obj[property] = createReturnSpy(returnValueFn, this)
    obj[property]

  through = ->
    after(restore)
    obj[property] = createThroughSpy(previous, this)
    obj[property]

  {
    to:       to
    return:   returnMethod
    through:  through
    restore:  restore
  }

bond.version = "0.0.8"

window?.bond = bond
module?.exports = bond
