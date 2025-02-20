# fantasmal-lang

**Disclaimer** The syntax used in this example is purely for design implementation and is likely non-functional.

```c
ghost const x = 50;
x = 675;
// x == 675
// x{-1} == 50
```

Ghostly constants act as mutable variables but are actually immutable variables that have their own values and store pointers to previous values.
So if you assigned x an initial value and then reassigned it twice the structure of each variable assignment would go something like this:

```c
ghost const int x = 10;
```

Whenever a ghostly constant is created or modified a respective "memory structure" is created behind the scenes and can be accessed directly if needed by caling `@<variable_name>[i]`, where i increases by 1 each time the value is "updated".

```c
// Behind the scene
@x[0] {
  value: 10,
  ptr: null
}
```

```c
x = 20;
```

```c
// Behind the scene
@x[1] {
  value: 20,
  ptr: {
    [-1]: @x[0]
  }
}
```

```c
x = 40;
```

```c
// Behind the scene
@x[2] {
  value: 40,
  ptr: {
    [-1]: @x[1],
    [-2]: @x[0]
  }
}
```

```c
print << x;
  // cout: 40

print << x{-1};
  // cout: 20

print << x{-2};
  // cout: 10
```

You could also chain ptr lookups like so:

```c
print << x{-1}{-1};
  // cout: 10
```

When a variable is assigned to `@x[0]` via the `=` operator, the value propagates to the variable as you'd expect from a regular constant in other languages.

```c
int y = @x[0];
  // y == 10 :true
```

If you were to try and change `@x[0]` directly, it would abide by constant rules and trigger an error.

```c
@x[0] = 30;
  // Error: Constant cannot have it's value reassigned
```
