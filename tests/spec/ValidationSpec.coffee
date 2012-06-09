describe 'Basic test', ->
  it 'true is true', ->
    expect(true).toBe(true)

describe 'Validation', ->
  beforeEach ->
    @success = ->
      expect(@v.errors_array().length).toBe(0)

  it 'can be created', ->
    v = new JSValid.Validation()
    expect(v.validate).toBeDefined()

  describe 'rule', ->
    beforeEach ->
      @v = new JSValid.Validation()

    it 'name is required', ->
      @v.validate('name', 'required')
      for value in [null, '']
        @v.isValid(name: value)
        expect(@v.errors_array()).toContain('name is required')

      @v.isValid(name: 'testing')
      @success()

    it 'email is a valid email address', ->
      @v.validate('email', 'email')
      for value in ['a@', 'a@a', '@a.com', 'foo@nice']
        @v.isValid(email: value)
        expect(@v.errors_array()).toContain('email is invalid')

      @v.isValid(email: 'foo@foo.com')
      @success()

    it 'name has a minimum length', ->
      @v.validate('name', 'min_length': 4)
      for value in ['', 'a', 'ab', 'abc']
        @v.isValid(name: value)
        expect(@v.errors_array())
          .toContain('name is too short. It must be atleast 4 characters long')

      @v.isValid(name: 'appl')
      @success()

    it 'name has a maximum length', ->
      @v.validate('name', 'max_length': 4)
      for value in ['abcde', 'abcdef', '9284912']
        @v.isValid(name: value)
        expect(@v.errors_array())
          .toContain('name is too long. It can be atmost 4 characters long')

      @v.isValid(name: 'appl')
      @success()

    it 'status must be active, suspended, or deleted', ->
      @v.validate('status', 'in': ['active', 'suspended', 'deleted'])
      for value in [null, '', 'apple', 'test', 123]
        @v.isValid(status: value)
        expect(@v.errors_array())
          .toContain('status must be (active,suspended,deleted)')

      @v.isValid(status: 'active')
      @success()

    it 'status cannot be active or deleted', ->
      @v.validate('status', 'ex': ['active', 'deleted'])
      for value in ['active', 'deleted']
        @v.isValid(status: value)
        expect(@v.errors_array())
          .toContain('status cannot be (active,deleted)')

      @v.isValid(status: 'suspended')
      @success()

    it 'validates format', ->
      @v.validate('cost', 'format': /^[0-9]+$/)
      for value in [null, '', 'apple', 'a0', '2a', '1a1']
        @v.isValid(cost: value)
        expect(@v.errors_array())
          .toContain("cost doesn't match format")

      @v.isValid(cost: 12)
      @success()

      @v.isValid(cost: '12')
      @success()

  describe 'complex rules', ->
    beforeEach ->
      @v = new JSValid.Validation()

    it 'email is required and valid', ->
      @v.validate('email', 'email', 'required')
      for value in [null, '']
        @v.isValid(email:  value)
        expect(@v.errors_array()).toContain('email is required')
        expect(@v.errors_array().length).toBe(1)

      for value in ['e@', 'e@e', 'e@e.c', '@foo.com']
        @v.isValid(email:  value)
        expect(@v.errors_array()).toContain('email is invalid')
        expect(@v.errors_array().length).toBe(1)

    it 'name must be between 4 to 8 characters long', ->
      @v.validate('name', { 'min_length': 4 }, { 'max_length': 8 })
      for value in [null, '', 'a', 'app']
        @v.isValid(name: value)
        expect(@v.errors_array())
          .toContain('name is too short. It must be atleast 4 characters long')
        expect(@v.errors_array().length).toBe(1)

      for value in ['testingit', '3990182982', 1928391283]
        @v.isValid(name: value)
        expect(@v.errors_array())
          .toContain('name is too long. It can be atmost 8 characters long')
        expect(@v.errors_array().length).toBe(1)