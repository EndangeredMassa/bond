{ok:expect} = require 'assert'
bond = require './bond.coffee'

describe 'bond', ->
  math =
    add: (a, b) ->
      a + b

  describe 'to', ->
    it 'replaces values', ->
      bond(math, 'add').to(-> 999)

      result = math.add(1, 2)
      expect result == 999

    it 'returns to original value', ->
      result = math.add(1, 2)
      expect result == 3

  describe 'return', ->
    it 'replaces methods', ->
      bond(math, 'add').return(888)

      result = math.add()
      expect result == 888

    it 'returns to original value', ->
      result = math.add(1, 2)
      expect result == 3

  describe 'through', ->
    it 'calls original method', ->
      bond(math, 'add').through()

      result = math.add(1, 2)
      expect result == 3

  describe 'spies with `through` and `return`', ->
    it 'records call count via called', ->
      bond(math, 'add').return(777)
      expect math.add.called == 0
      math.add(1, 2)
      expect math.add.called == 1
      math.add(1, 2)
      expect math.add.called == 2

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

      expect math.add.calledArgs[0][0] == 111
      expect math.add.calledArgs[0][1] == 222
      expect math.add.calledArgs[1][0] == 333
      expect math.add.calledArgs[1][1] == 444

    it 'returns the spy', ->
      spy = bond(math, 'add').through()
      math.add(1, 2)
      expect spy.called

