== after callback registration ==

If we use `after` to revert the stubbed values, it is only called at the very end of the suite run.
It must be called on the global context. Find out how to call it with the current test context.

