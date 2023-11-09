Going to write down important notes here, could save a lot of time with debugging.

- Don’t worry about calling `:dispose()` methods on script shutdown.

  You don’t have to call it at all, resources will be cleared up once garbage collector gets to the thing, but generally you might want to use if you need to, for example, recreate a bunch of render targets (aka `ui.ExtraCanvas`) and want for VRAM to be released as soon as possible rather than waiting for GC.

- Don’t hardcode enum values.

  Might seem like a neat idea to replace something like `ui.StyleVar.FramePadding` in your code with `18`, especially if you need to combine a few flags together, but please avoid doing it at all costs! Actual values might change in the future, as they were already in the past. If you are concern about performance, there is a solution. And as for combining a few flags together, although sometimes with powers of two you can just do something like `ui.ButtonFlags.Active + ui.ButtonFlags.DontClosePopups`, consider using `bit.bor()` instead ([more details about `bit` module](http://bitop.luajit.org/api.html)).

- Don’t add custom things to default namespaces.

  Currently there is a `script` table in the global namespace, mostly containing `update(dt)` function to be called each frame. You might want to add something like `script.myOwnFunction()`, but please avoid doing so: future CSP updates could add start calling more functions from that `script` table in certain cases, and it might lead to unpredicted results. For example, scripts for car physics now call `script.reset()` when car is being teleported back to pits or the session is restarted, expecting a script to reset its temporary state.

  Also, it might not work all that well to add new functions to tables like `table`, `math` or `string`. Standard CSP library often expands those tables adding more functionality (some of it can be implemented on C++ side for better performance), which could be overwritten by your extensions, and while most CSP library wouldn’t be affected, additional code might start to rely on those functions with their exact implementation.

- Avoid using things starting with “_”.

  For example, the whole “__util” table. Those aren’t guaranteed to continue to work as they are working now. In general, if something is not in LDocs it might be changed later.

- Make sure to not pass extra arguments to standard library functions, or add extra undocumented arguments to callbacks as empty local variables.

  With future updates those functions and callbacks might get more arguments breaking your code.

- Use `stringify` to encode and decode data.

  Or even `stringify.binary` if you don’t need data to be readable. Those functions can automatically deal with vectors, matrices and 1D LUTs too, and should run pretty fast, especially binary version. And there is also a built-in `JSON` module, which should be pretty fast, although it has a caveat that it can parse anything and never through an error. Sometimes you might not want that.

- Use timers for slow updates.

  If you’re working on a script which needs to do some task every second, and don’t need `script.update()` otherwise, instead of writing `script.update()` to check time and skip unnecessary frames simply use `setInterval()` and C++ part won’t need to call your script every frame for it to do nothing.

- Some scripts have full I/O access, some don’t.

  Lua apps, as well as pretty much all scripts user installs explicitly (like, for example, fireworks behavior or a post-processing filter) have full access to things like reading files, accessing memory mapped files, launching processes, etc., similar to how original Python apps worked (that’s why Content Manager now should warn about it during scripts installation). Sometimes it can be beneficial, for example if you want to have something like post-processing effect integrated with some eye tracking service. However, scripts for cars or tracks, as well as online scripts, of course, don’t have that access, so they wouldn’t be able to launch any processes, read files outside of their folders, write any files, load any DLLs, etc.

- Some additional libraries are available in “extension\internal\lua-shared” folder.
 
  You can access them with something like `require('shared/ui/virtualizing')` (there is basically a “extension\internal\lua-?” path added by default for module lookup).

- Lua sockets library is already included.

  Currently it’s not available to scripts without full I/O though. But other than that, everything is compiled, linked and ready to be used.

- Don’t overly rely on FFI part.

  For a few reasons (such as compatibility concerts) FFI is pretty restricted here, so calling `ffi.load()`, for example, won’t do anything. If you want some extra binary functions, consider moving them in a separate process instead, and use memory-mapped structures to exchange data. In general, if it’s documented in Lua SDK docs, feel free to use it, but otherwise, especially with ABI stuff, things are not guaranteed to be compatible at all.