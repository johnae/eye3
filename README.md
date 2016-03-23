[![Circle CI](https://circleci.com/gh/johnae/eye3.svg?style=svg)](https://circleci.com/gh/johnae/eye3)

## Eye3

Eye3 is a flexible scheduler for your i3 bar. So if you're using the [i3 window manager](https://i3wm.org/) it may be intersting
to you. Also, any other wm with a compatible protocol should work like for example [sway](http://swaywm.org/).

It's highly programmable through the super fast built in [LuaJIT VM](http://luajit.org/) and [moonscript](https://github.com/leafo/moonscript).

It's very early and bit hacky atm. Some notable features are:

Built in [ljsyscall](https://github.com/justincormack/ljsyscall) which means you can call into the kernel and have those calls be as fast as if you called
them from C. For example the net throughput built in is doing this.

Coroutines are used to mitigate the callback soup that easily ensues when using libuv (as in nodejs).

Click and scroll events work.

Building eye3 requires the usual tools + cmake, so you may need to to apt-get/brew/yum/etc install cmake before
building it. Otherwise it should be as straightforward as:

```
make
```

After that you should have an executable called eye3. It's known to build on Linux atm.
Everything in the lib directory and toplevel is part of spook itself, anything in vendor and deps
is other peoples work and is just included in the resulting executable.


Installation is as straightforward as:

```
PREFIX=/usr/local make install
```

Running eye3 is a matter of doing this:

```
eye3 path/to/config
```

So that is what you want to do in your i3 config to use this as the bar scheduler. If you're curious about
how to go about writing a config file, have a look at the example_config included in the repo.

A slightly similar project, especially similar in it's small memory/cpu footprint would be [i3blocks](https://github.com/vivien/i3blocks). This
project was actually started as a fun thing for me to do but I also wanted less shelling out by building in a scripting language. At least it should
be possible to lower the cpu footprint by using eye3 as opposed to i3blocks but... honestly - it's mostly a fun thing for me to do atm and i3blocks
is also a very good i3 bar scheduler.

Again - I've thrown this together pretty quickly and it's very rough all over atm.
