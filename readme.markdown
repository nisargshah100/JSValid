# JSValid

Is a small but flexible javascript validation library that offers similar validation capabilities as Rails. 

## Crash Course

All the examples below are in coffeescript. If you want see them in javascript, http://js2coffee.org/ is an awesome tool which can convert the snippets for you.

### Email Validation

```
validation = new JSValid.Validation()
validation.validate('email_address', 'required', 'email')
```

Testing for validation:

```
validation.isValid({'email_address': 'Testing'})
console.log(validation.errors())
console.log(validation.errors_array())
```

#### Custom Error Message

```
validation.validate('email_address',
  'required', 
  'email': {
    'message': 'Email Address is invalid'
  }
)
```

Every validator has a message attribute that can be specified for a custom validation message.

### Complex Validation

We need to validate the email to be between 4 - 30 characters long and only letters.

```
validation.validate('name', 
  'min_length': 4, 
  'max_length': 30, 
  'format': /^[a-zA-Z]*$/
)
```

What about a custom validation messages?

```
validation.validate('name',
  'min_length': { value: 4, message: 'Too Short!' },
  'max_length': { value: 30, message: 'Too Long!' },
  'format': { value: /^[a-zA-Z]*$/, message: 'Letters!' }
)
```

### Defining your own rules

On of the main goals of this library was to make it as flexible as possible. If you want to define your own rules, it very easy!

#### Lets Define a Alpha Rule (for letters only)

```
class Alpha
  constructor: (name, params) ->
    @message ||= params?.message || "#{name} must be letters only"
    
  validate: (obj) ->
    @message if obj? and obj.match /^[a-zA-Z]+$/

# Now add the validator to the validation lib.
JSValid.Validation.rules['alpha'] = Alpha

```

The validator has two parts. The initial constructor takes the name of the field and the set of parameters that are passed through. To call your validator, you need to use:

`validation.validate('name', 'alpha')`

But if you have additional parameters, they will be passed through to the validator also!

`validation.validate('name', 'alpha': { foo: 1 })`

The { foo: 1 } will be passed into your validator as params in the constructor. This allows you to add as many params as you want when the rule is defined. The second part is the validate method. This is called with the object that needs to be validated. In the above example, obj['name'] would be passed into your validate method. 

#### Enjoy!