{ok:expect, equal} = require 'assert'
bond = require './lib/bond'

describe 'bond', ->
  math =
    PI: Math.PI

    abs: Math.abs

    add: (a, b) ->
      a + b

    subtract: (a, b) ->
      a - b

    ComplexNumber: (@real, @imaginary) ->
      this.toString = ->
        "#{@real} + #{@imaginary}i"

  describe '#bond', ->
    describe 'when called with 0 args', ->
      it 'returns a simple spy', ->
        spy = bond()
        expect !spy.called

        spy()
        expect spy.called

      it 'returns a spy that can have a return value', ->
        spy = bond().return(3)
        result = spy()
        equal result, 3

    it 'returns the bond api when called with 2 args', ->
      api = bond(math, 'add')
      expect api.to
      expect api.return
      expect api.through
      expect api.restore

  describe 'to', ->
    describe 'non function values', ->
      it 'replaces values', ->
        bond(math, 'PI').to 3.14

        equal math.PI, 3.14

      it 'returns to original value', ->
        equal math.PI, 3.141592653589793

    describe 'function values', ->
      it 'creates a through spy', ->
        bond(math, 'subtract').to (x, y) -> math.abs(x - y)

        result = math.subtract(5, 10)

        equal result, 5
        equal math.subtract.called, 1
        expect math.subtract.calledWith(5, 10)

      it 'returns the original values', ->
        result = math.subtract(5, 10)
        equal result, -5


  describe 'return', ->
    it 'replaces methods', ->
      bond(math, 'add').return(888)

      result = math.add()
      equal result, 888

    it 'returns to original value', ->
      result = math.add(1, 2)
      equal result, 3

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
        expect !error
        equal value1, stubValue1
        equal value2, stubValue2
        done()

    it 'calls the callback with an error', (done) ->
      ignoredValue = 5
      stubError = 1
      bond(module, 'useNodeCallback').asyncReturn(stubError)
      module.useNodeCallback ignoredValue, (error) ->
        equal error, stubError
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

      expect error

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
      expect !callbackSpy.called

  describe 'through', ->
    it 'calls original method', ->
      bond(math, 'add').through()

      result = math.add(1, 2)
      equal result, 3

  describe 'restore', ->
    it 'restores the original property', ->
      original = math.add
      bond(math,'add').through()
      expect original != math.add
      math.add.restore()
      expect original == math.add

  describe 'spies with `through` and `return`', ->
    it 'returns the bond api mixed into the returned spy', ->
      for method in ['through', 'return']
        bond(math, 'add')[method]()
        expect math.add.to
        expect math.add.return
        expect math.add.through
        expect math.add.restore

    it 'allows the spy to be replaced with new spies via the mixed-in api', ->
      bond(math,'add').return(123)
      result = math.add(1, 2)
      equal result, 123

      math.add.return(321)
      result = math.add(1, 2)
      equal result, 321

      math.add.through()
      result = math.add(1, 2)
      equal result, 3

      math.add.return(123)
      result = math.add(1, 2)
      equal result, 123

    it 'records call count via called', ->
      bond(math, 'add').return(777)
      equal math.add.called, 0
      math.add(1, 2)
      equal math.add.called, 1
      math.add(1, 2)
      equal math.add.called, 2

    it 'records called via called', ->
      bond(math, 'add').through()
      expect !math.add.called
      math.add(1, 2)
      expect math.add.called

    it 'responds to calledWith(args...)', ->
      bond(math, 'add').return(666)
      expect !math.add.calledWith(11, 22)
      math.add(11, 22)
      expect math.add.calledWith(11, 22)

    it 'exposes argsForCall', ->
      bond(math, 'add').return(555)

      math.add(111, 222)
      math.add(333, 444)

      equal math.add.calledArgs[0][0], 111
      equal math.add.calledArgs[0][1], 222
      equal math.add.calledArgs[1][0], 333
      equal math.add.calledArgs[1][1], 444

    it 'returns the spy', ->
      spy = bond(math, 'add').through()
      math.add(1, 2)
      expect spy.called

    it 'through is constructor safe', ->
      bond(math, 'ComplexNumber').through()
      result = new math.ComplexNumber(3, 4)

      equal result.real, 3
      equal result.imaginary, 4
      expect math.ComplexNumber.called

    it 'return is constructor safe', ->
      number =
        real: 1
        imaginary: 2
      bond(math, 'ComplexNumber').return(number)
      result = new math.ComplexNumber(3, 4)

      equal result, number

