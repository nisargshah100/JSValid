JSValid = {}
JSValid.Validator = {}

class JSValid.Validator.RequiredValidation
  constructor: (name, params) ->
    @message = params?.message || "#{name} is required"

  validate: (obj) ->
    @message if not obj? or obj is ''

class JSValid.Validator.MinLengthValidation
  constructor: (name, params) ->
    @length = params if params and typeof(params) is 'number'
    @length ||= params?.value || 6
    @message ||= params?.message || "#{name} is too short. It must be atleast #{@length} characters long"

  validate: (obj, name) ->
    @message if not obj? or String(obj).length < @length

class JSValid.Validator.MaxLengthValidation
  constructor: (name, params) ->
    @length = params if params and typeof(params) is 'number'
    @length ||= params?.value || 6
    @message ||= params?.message || "#{name} is too long. It can be atmost #{@length} characters long"

  validate: (obj) ->
    @message if obj? and String(obj).length > @length

class JSValid.Validator.EmailValidation
  constructor: (name, params) ->
    @message ||= params?.message || "#{name} is invalid"

  validate: (obj) ->
    match = obj.match /^[-a-z0-9~!$%^&*_=+}{\'?]+(\.[-a-z0-9~!$%^&*_=+}{\'?]+)*@([a-z0-9_][-a-z0-9_]*(\.[-a-z0-9_]+)*\.(aero|arpa|biz|com|coop|edu|gov|info|int|mil|museum|name|net|org|pro|travel|mobi|[a-z][a-z])|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(:[0-9]{1,5})?$/i if obj?
    @message if not match and obj? and not (obj == '')

class JSValid.Validator.InclusionValidation
  constructor: (name, params) ->
    @in = params if params and JSValid.Validation.isArray(params)
    @in ||= params?.value || []
    @message ||= params?.message || "#{name} must be (#{@in.join(',')})"

  validate: (obj) ->
    @message if obj not in @in

class JSValid.Validator.ExclusionValidation
  constructor: (name, params) ->
    @ex = params if params and JSValid.Validation.isArray(params)
    @ex ||= params?.value || []
    @message ||= params?.message || "#{name} cannot be (#{@ex.join(',')})"

  validate: (obj) ->
    @message if obj in @ex

class JSValid.Validator.FormatValidation
  constructor: (name, params) ->
    @message ||= params?.message || "#{name} doesn't match format"
    @format = params if (params instanceof RegExp)
    @format ||= params?.value || RegExp()

  validate: (obj) ->
    @message if not String(obj).match @format

class JSValid.Validation
  constructor: ->
    @validators = {}
    @errors = {}

  @rules =
    'required': JSValid.Validator.RequiredValidation
    'min_length': JSValid.Validator.MinLengthValidation
    'max_length': JSValid.Validator.MaxLengthValidation
    'email': JSValid.Validator.EmailValidation
    'in': JSValid.Validator.InclusionValidation
    'ex': JSValid.Validator.ExclusionValidation
    'format': JSValid.Validator.FormatValidation

  @isArray = (obj) ->
    Object.prototype.toString.apply(obj) is '[object Array]';

  @flatten = (array) ->
    flat = []
    i = 0
    l = array.length

    while i < l
      type = Object::toString.call(array[i]).split(" ").pop().split("]").shift().toLowerCase()
      flat = flat.concat((if /^(array|collection|arguments|object)$/.test(type) then JSValid.Validation.flatten(array[i]) else array[i]))  if type
      i++
    flat

  errors_array: ->
    JSValid.Validation.flatten(@errors[error] for error of @errors)

  getRule: (rule) ->
    if typeof(rule) is 'string'
      rule
    else
      props = (key for key of rule)
      if props.length > 0 then props[0] else null

  validate: (attr, rules...) ->
    for rule_object in rules
      rule = @getRule(rule_object)
      validator = Validation.rules[rule]
      @validators[attr] ||= []
      @validators[attr].push(new validator(attr, rule_object[rule])) if validator

  isValid: (obj) ->
    @errors = {}
    for attr of @validators
      for validator in @validators[attr]
        result = validator.validate(obj[attr])
        if result
          @errors[attr] ||= []
          @errors[attr].push(result)

    @errors_array().length is 0

window.JSValid = JSValid