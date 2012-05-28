(exports ? window).Profiler = new class
  stack: null
  log: []
  path: []

  getDetails:(Path, root) ->
    tmp = Path.split(".")
    Name = tmp.pop()
    Parent = root
    while (next = tmp.shift())?.length
      Parent = Parent[next]
    if !Parent?[Name]?
      throw "Invalid path #{Path}"
    return {Name, Parent}

  wrap: (fn, name) ->
    if fn.__profilerWrapped
      return fn
    self = @
    replacement = ->
      stack = self.stack
      self.stack = []

      self.path.push name
      start = new Date().getTime()
      result = fn.apply(@, arguments)
      log = "#{self.path.join(",")} #{new Date().getTime()-start}"
      self.path.pop()

      self.stack.unshift log
      if stack?
        stack.push l for l in self.stack
      else
        self.log.push l for l in self.stack
      self.stack = stack

      return result

    for own key of fn
      replacement[key] = fn[key]
    replacement.prototype = fn.prototype
    replacement.__profilerWrapped = true
    return replacement

  registerFunction: (Path, root = (window ? global)) ->
    {Name, Parent} = @getDetails(Path, root)
    Parent[Name] = @wrap(Parent[Name],Path)
    return

  registerConstructor: (Path, root = (window ? global)) ->
    {Name, Parent} = @getDetails(Path, root)
    @registerFunction Path, root
    for k of Parent[Name].prototype
      if typeof Parent[Name].prototype[k] is 'function'
        Parent[Name].prototype[k] = @wrap Parent[Name].prototype[k], "#{Path}::#{k}"
    return
