
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

  undefined
