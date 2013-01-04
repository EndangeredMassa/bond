{ok:expect, equal} = require 'assert'
bond = require './bond.coffee'

describe 'bond', ->
  math =
    add: (a, b) ->
      a + b

    ComplexNumber: (@real, @imaginary) ->
      this.toString = ->
        "#{@real} + #{@imaginary}i"

  describe '#bond', ->
    it 'returns a spy when called with 0 args', ->
      spy = bond()
      expect !spy.called

      spy()
      expect spy.called

    it 'returns the bond api when called with 2 args', ->
      api = bond(math, 'add')
      expect api.to
      expect api.return
      expect api.through

  describe 'to', ->
    it 'replaces values', ->
      bond(math, 'add').to(-> 999)

      result = math.add(1, 2)
      equal result, 999

    it 'returns to original value', ->
      result = math.add(1, 2)
      equal result, 3

  describe 'return', ->
    it 'replaces methods', ->
      bond(math, 'add').return(888)

      result = math.add()
      equal result, 888

    it 'returns to original value', ->
      result = math.add(1, 2)
      equal result, 3

  describe 'through', ->
    it 'calls original method', ->
      bond(math, 'add').through()

      result = math.add(1, 2)
      equal result, 3

  describe 'spies with `through` and `return`', ->
    it 'reports missing properties', ->
      errorMessage = null
      try
        bond(math, 'non-existant').through()
      catch e
        errorMessage = e.message

      equal errorMessage, 'Could not find property non-existant.'

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

