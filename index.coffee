
# ## UMD
umd = ( name, factory ) ->
  # AMD
  if "function" is typeof define and define.amd
    define factory
  # CJS
  else if "undefined" isnt typeof module
    module.exports = do factory
  # global
  else
    _old = window[name]
    _new = do factory
    window[name] = _new

    _new.noConflict = ->
      window[name] = _old
      return _new

# ## Factory
umd "random", ->

  # store last seed
  _seed = null
  # store current random function
  _random = Math.random

  _o_ =
  # provide method for seeding random
  seed: ( seed ) ->
    if seed?
      _seed = seed
      if seed instanceof Function
        # allow custom for potential crypto methods
        _random = seed
      else
        _random = ->
          # not cryptographically sound, but functional
          x = 10000 * Math.sin seed++
          x - Math.floor x
    else
      # when no seed specified revert to random
      _seed = null
      _random = Math.random

  # restart the seed
  reseed: ( ) ->
    @seed _seed

  # convenience wrapper for resuming math random
  unseed: ( ) ->
    do @seed

  # generate random boolean value
  bool: ( ) -> do _random < 0.5

  # generate random number
  number: ( lo, hi ) ->
    # work from 0 if no lower bound specified
    unless hi
      hi = lo
      lo = 0
    # cast to numbers
    lo = parseFloat lo
    hi = parseFloat hi
    # swap values if not in order
    if hi < lo
      lo ^= hi
      hi ^= lo
      lo ^= hi
    do _random * (hi - lo) + lo

  # generate random integer
  integer: ( lo, hi ) ->
    Math.floor @number lo, hi

  # pick random item from collection
  choose: ( collection, other ) ->
    if other?
      collection = Array::slice.apply arguments
    collection[@integer collection.length]

  # default alphabet, roman characters
  ALPHA: "qwertyuiopasdfghjklzxcvbnm"
  ALPHA_NUMERIC: "qwertyuiopasdfghjklzxcvbnm1234567890"

  # generate random letter
  letter: ( alphabet ) ->
    @choose alphabet or @ALPHA

  # generate alpha numeric character
  alphanumeric: ( ) ->
    @choose @ALPHA_NUMERIC

  # generate date
  date: ( lo, hi ) ->
    unless lo
      # start from now if not specified
      lo = new Date
    # ensure items are dates
    else unless lo instanceof Date
      lo = new Date lo
    # convert to timestamps
    lo = do lo.getTime
    if hi and not hi instanceof Date
      hi = new Date hi
      hi = do hi.getTime

    # generate random time and new date
    return new Date @integer lo, hi

  # generate random string
  string: ( format ) ->
    # example
    #  - GUID: [a{8}]-[a{4}]-[a{4}]-[a{4}]-[a{12}]
    format.replace /\[(.+?)(?:\((.*)\))?(?:{(\d+)})?(\?)?\]/g,
      ( match, name, params, count, maybe ) =>
        return "" if maybe and do @bool
        match = ""
        count or= 1
        if params
          params = params.split(",").map ( item ) =>
            if (item.indexOf "@") then item else this[item]
        else
          params = [ ]
        while count--
          match += @[name].apply this, params
        return match

  # tiny api
  _o_.b = _o_.bool
  _o_.n = _o_.number
  _o_.i = _o_.integer
  _o_.l = _o_.letter
  _o_.a = _o_.alphanumeric
  _o_.d = _o_.date
  _o_.s = _o_.string

  return _o_

