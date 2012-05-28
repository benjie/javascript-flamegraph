JavaScript-FlameGraph
=====================

Profiles JavaScript code, and then generates a [FlameGraph][] to aid
performance debugging.

Getting started:

    git clone git://github.com/BenjieGillam/javascript-flamegraph.git
    git submodule update --init
    npm install

Then include `profiler.js` in your project.

Profiling
---------

First you need to profile your JavaScript, which you can do with the
included profiler. Simply call `Profiler.registerConstructor` on any
classes you want to analyse - note that the parameter to this function
is the string path to the variable from the root object (which defaults
to `window`).

    class Bob
      method: ->
        // Do something

    Profiler.registerConstructor "Bob"

If you need to do analysis inside of a closure then add your class as a
property of another object, and pass this object as the second
parameter.

    (function() {
      var fn = function() {
        //...
      };
      fn.Klass = function() {
        //...
        return this;
      };
      var details = {MyFunc:fn};
      Profiler.registerFunction("MyFunc",details);
      Profiler.registerConstructor("MyFunc.Klass",details);
    })();

### Collecting the data

Data is stored in `Profiler.log` - get this to your computer somehow
(e.g. via an `XMLHTTPRequest` and `JSON.stringify`).

Graphing
--------

    coffee flamegraph.coffee path/to/details.json

This will create `path/to/details.json.svg` which you can then view in
your SVG viewer of choice.

License
-------
WTFPL v2 or later.
(If you want a different license then just tweet me [@benjiegillam][])

[@benjiegillam]: http://twitter.com/benjiegillam
[FlameGraph]: https://github.com/brendangregg/FlameGraph/
