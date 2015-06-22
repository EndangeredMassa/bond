{truthy, falsey, equal, deepEqual, hasType} = require 'assertive'
bond = require './lib/bond'

describe 'bond', ->
  math =
    PI: Math.PI

    zero: 0

    abs: Math.abs

    add: (a, b) ->
      a + b

    subtract: (a, b) ->
      a - b

    ComplexNumber: (@real, @imaginary) ->
      this.toString = ->
        "#{@real} + #{@imaginary}i"

    NumberObject: (number) ->
      return {number}

  describe '#bond', ->
    describe 'when called with 0 args', ->
      it 'returns a simple spy', ->
        spy = bond()
        falsey spy.called

        spy()
        equal 1, spy.called

      it 'returns a spy that can have a return value', ->
        spy = bond().return(3)
        result = spy()
        equal 3, result

    it 'returns the bond api when called with 2 args', ->
      api = bond(math, 'add')
      hasType Function, api.to
      hasType Function, api.return
      hasType Function, api.through
      hasType Function, api.restore

  describe 'to', ->
    describe 'can replace earlier bound values', ->
      # these tests must be run in this specific order;
      # do not bond math.zero in any other test
      # because a failure here will cause test suite pollution
      it 'setup', ->
        bond(math, 'zero').to 3.14
        bond(math, 'zero').to 12

        equal math.zero, 12

      it 'test', ->
        # test that the old replacements have been cleared away
        equal math.zero, 0

    describe 'non function values', ->
      it 'replaces values', ->
        bond(math, 'PI').to 3.14

        equal 3.14, math.PI

      it 'returns to original value', ->
        equal 3.141592653589793, math.PI

    describe 'function values', ->
      it 'creates a through spy', ->
        bond(math, 'subtract').to (x, y) -> math.abs(x - y)

        result = math.subtract(5, 10)

        equal 5, result
        equal 1, math.subtract.called
        equal true, math.subtract.calledWith(5, 10)

      it 'returns the original values', ->
        equal -5, math.subtract(5, 10)

      it 'explicitly returns objects from constructors', ->
        bond(math, 'NumberObject').to -> {number: 7}

        deepEqual {number: 7}, new math.NumberObject()

      it "doesn't return non-objects from constructors", ->
        bond(math, 'NumberObject').to ->
          @numero = 42
          return 'I should not be returned'

        result = new math.NumberObject()
        equal 42, result.numero

  describe 'return', ->
    it 'replaces methods', ->
      bond(math, 'add').return(888)

      result = math.add()
      equal 888, result

    it 'returns to original value', ->
      result = math.add(1, 2)
      equal 3, result

  describe 'asyncReturn', ->
    module =
      useNodeCallback: (value1, value2, callback) ->
        throw new Error
      dontUseNodeCallback: (value1, value2) ->
        throw new Error

    it 'calls the last argument with the provided arguments', (done) ->
      ignoredValue1 = 5
      ignoredValue2 = 4
      stubValue1 = 3
      stubValue2 = 2
      bond(module, 'useNodeCallback').asyncReturn(null, stubValue1, stubValue2)
      module.useNodeCallback ignoredValue1, ignoredValue2, (error, value1, value2) ->
        falsey error
        equal stubValue1, value1
        equal stubValue2, value2
        done()

    it 'calls the callback with an error', (done) ->
      ignoredValue = 5
      stubError = 1
      bond(module, 'useNodeCallback').asyncReturn(stubError)
      module.useNodeCallback ignoredValue, (error) ->
        equal stubError, error
        done()

    it 'throws an error if the last argument is not a function', ->
      ignoredValue = 5
      stubValue = 2
      error = null
      bond(module, 'dontUseNodeCallback').asyncReturn(stubValue)

      try
        module.useNodeCallback ignoredValue
      catch err
        error = err

      truthy error

    it 'calls the callback on the next tick', (done) ->
      ignoredValue = 5
      stubValue = 3

      module2 =
        work: ->
          done()
      callbackSpy = bond(module2, 'work').through()

      bond(module, 'useNodeCallback').asyncReturn(stubValue)
      module.useNodeCallback ignoredValue, callbackSpy

      # this will fail if the callback is called immediately
      falsey callbackSpy.called

  describe 'through', ->
    it 'calls original method', ->
      bond(math, 'add').through()

      equal 3, math.add(1, 2)

    it 'explicitly returns objects from constructors', ->
      bond(math, 'NumberObject').through()

      result = new math.NumberObject(42)
      equal 42, result.number

  describe 'restore', ->
    it 'restores the original property', ->
      original = math.add
      bond(math,'add').through()
      truthy original != math.add
      math.add.restore()
      truthy original == math.add

  describe 'spies with `through` and `return`', ->
    it 'returns the bond api mixed into the returned spy', ->
      for method in ['through', 'return']
        bond(math, 'add')[method]()
        truthy math.add.to
        truthy math.add.return
        truthy math.add.through
        truthy math.add.restore

    it 'allows the spy to be replaced with new spies via the mixed-in api', ->
      bond(math,'add').return(123)
      equal 123, result = math.add(1, 2)

      math.add.return(321)
      equal 321, result = math.add(1, 2)

      math.add.through()
      equal 3, result = math.add(1, 2)

      math.add.return(123)
      equal 123, result = math.add(1, 2)

    it 'records call count via called', ->
      bond(math, 'add').return(777)
      equal 0, math.add.called
      math.add(1, 2)
      equal 1, math.add.called
      math.add(1, 2)
      equal 2, math.add.called

    it 'records called via called', ->
      bond(math, 'add').through()
      falsey math.add.called
      math.add(1, 2)
      truthy math.add.called

    it 'responds to calledWith(args...)', ->
      bond(math, 'add').return(666)
      falsey math.add.calledWith(11, 22)
      math.add(11, 22)
      truthy math.add.calledWith(11, 22)

    it 'exposes argsForCall', ->
      bond(math, 'add').return(555)

      math.add(111, 222)
      math.add(333, 444)

      deepEqual [
        [111, 222]
        [333, 444]
      ], math.add.calledArgs

    it 'returns the spy', ->
      spy = bond(math, 'add').through()
      math.add(1, 2)
      equal 1, spy.called

    it 'through is constructor safe', ->
      bond(math, 'ComplexNumber').through()
      result = new math.ComplexNumber(3, 4)

      equal 3, result.real
      equal 4, result.imaginary
      equal 1, math.ComplexNumber.called

    it 'return is constructor safe', ->
      number =
        real: 1
        imaginary: 2
      bond(math, 'ComplexNumber').return(number)
      equal number, new math.ComplexNumber(3, 4)
