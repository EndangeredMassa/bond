createThroughSpy = (getValue) ->
  spy = ->
    args = Array::slice.call(arguments)
    spy.calledArgs[spy.called] = args
    spy.called++

    isConstructor = Object.keys(this).length == 0

    result = getValue.apply(this, args)

    # not sure why return value matters with `new` call
    return this if isConstructor
    result

  enhanceSpy(spy, getValue)

createReturnSpy = (getValue) ->
  spy = ->
    args = Array::slice.call(arguments)
    spy.calledArgs[spy.called] = args
    spy.called++

    getValue.apply(this, args)

  enhanceSpy(spy, getValue)

enhanceSpy = (spy, original) ->
  spy.prototype = original.prototype
  spy.called = 0
  spy.calledArgs = []
  spy.calledWith = (args...) ->
    return false if !spy.called
    lastArgs = spy.calledArgs[spy.called-1]
    arrayEqual(args, lastArgs)
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

  to = (newValue) ->
    unregistered = false
    afterEach ->
      return if unregistered
      obj[property] = previous
      unregistered = true

    obj[property] = newValue
    obj[property]

  returnMethod = (returnValue) ->
    unregistered = false
    afterEach ->
      return if unregistered
      obj[property] = previous
      unregistered = true

    obj[property] = createReturnSpy -> returnValue
    obj[property]

  through = ->
    unregistered = false
    afterEach ->
      return if unregistered
      obj[property] = previous
      unregistered = true

    obj[property] = createThroughSpy(previous)
    obj[property]

  {
    to: to
    return: returnMethod
    through: through
  }

window?.bond = bond
module?.exports = bond
