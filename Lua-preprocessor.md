When loading Lua scripts, CSP also precompiles them, slowing down first launch, but making subsequent launches faster (that’s what all those files in “AssettoCorsa\cache\lua” are for).

But during that step there is another thing CSP does since v0.1.80-preview400: it runs a simplest preprocessor which can help with performance. It doesn’t add any syntax sugar or anything, but if you want squeeze extra bit of performance out of your scripts, it might help.

*Currently, preprocessor only runs on Lua scripts starting with `---@ext` or `---@ext:verbose`, with latter one CSP will also print the final code in its log file. Alternatively, set `FORCE_LUA_PREPROCESSOR=1` in “extension/config/general.ini” and it’ll run everywhere. Once we can be sure it won’t mess up everything, it’ll be enabled everywhere by default.*

# Features

### Enum inlining

Preprocessor automatically replaces CSP enums (such as, for example, “ac.Wheel.FrontRight”) by the corresponding numerical value. Feel free to use actual enums and don’t worry about performance impact anymore.

### Resolution for `bit.`

Calls to `bit.band()` and `bit.bor()` can be resolved during preprocess stage if their arguments are constants or enums.

### Const helper

That’s the biggest one. There is a new function in CSP library now called `const` which is implemented like this: `function const(x) return x end`. Nothing special, but preprocessor can detect its calls and process code in a few different special ways, with the assumption that whatever is inside `const()` call won’t change in the future. And if for one or another reason preprocessor won’t be able to resolve such a value, it won’t affect actual behaviour anyway!

Here is what this function can be used for:

- Const computation
  - Before
    ```lua
    local value = const(math.pow(math.pi / math.pow(2, 0.1), 4.71))
    ```
  - After
    ```lua
    local value = 158.41298314282
    ```
  This stuff can be used for things like conditions, for example, you can replace `if ac.getPatchVersionCode() > 2000 then …` by `if const(ac.getPatchVersionCode() > 2000) then …`, making branch cheaper. While API for those `const()` calls is limited and not all functions are available, calling something unavailable will simply abort resolution of this particular call, so no big deal.
- Const definition
  - Before
    ```lua
    local myConst = const(17)
    callSomething(myConst)
    ```
  - After
    ```lua
    --cal myConst = const(17)
    callSomething(17)
    ```
  This is what lead me to develop the thing, LuaJIT is not entirely perfect when it comes to resolving constants like that, so I found myself inlining values manually resulting in pretty hard to deal with code. Well, now it’s no longer a concern. And as you can see from that example, if name of a constant is not mentioned anywhere it couldn’t be replaced in, the actual definition will be commented out saving some memory. 

  Other types, such as strings or tables, are also supported:
  - Before
    ```lua
    local myConstTable = const(({ key = 2 * myConst }))
    callSomething(myConstTable.key)
    ```
  - After
    ```lua
    --cal myConstTable = const(({ key = 2 * myConst }))
    callSomething(34)
    ```
  One caveat: tables will be inlined only if the code always refers to primitive table properties and never to a table itself. Otherwise, inlining it wouldn’t make a lot of sense.

- Functions
  - Before
    ```lua
    local sumNumbers = const(function(x, y) return x + y end)
    callSomething(sumNumbers(1, 2), sumNumbers(A, B))
    ```
  - After
    ```lua
    --cal sumNumbers = const(function(x, y) return x + y end)
    callSomething(3, A + B)
    ```
  This one can kind of mimic C macros in a strange way. Again, fully resolvable when possible, but if not, it’ll at least substitute call with the arguments. Might not always be the best idea to use it, but sometimes it might help.

- A heavier computation
  - Before
    ```lua
    local fibonacci = const((function () 
      local function loop(n)
        if n == 0 then
          return 0
        elseif n == 1 or n == 2 then
          return 1
        else
          local f1, f2, f3 = 1, 1, 1
          for _ = 3, n do
            f3 = f1 + f2
            f1 = f2
            f2 = f3
          end
          return f3
        end
      end
      local result = {}
      for i = 1, 10 do
        result[i] = loop(i)
      end
      return result
    end)())
    ```
  - After
    ```lua
    local fibonacci = { 1, 1, 2, 3, 5, 8, 13, 21, 34, 55 }
    ```
  CSP uses `stringify()` to turn complex types returned by `const()` to Lua-parseable values, so everything like vectors or matrices would also work.

# Uses

One good use for this system is for car physics scripts, where performance is really important. For example, you can move some of the settings in INI and LUT files, load them into const tables and then refer to them from your code, and from Lua perspective all those values will become constants, working even faster than if they’d be defined in Lua files directly. And don’t worry about editing: physics scripts specifically will be recompiled when any of files in data folder (or in “data.acd” file) change.

Another potentially interesting use case is to use `const()` to prepare some Lua script itself, not just inlining some config-based settings, but altering the entire code logic, and then passing the result to `loadstring()`. Basic `loadstring(const(…))` will do the trick. 