# Recursive MACROS

## What happens if you recursively call a macro function?

Can macros be called recursively like a function? <br>
Does a statement like this create an infinite recursion? <br>
```
#define sum(a, b) (sum(a , b))
```

The answer is NO. Since a macro does not comprehend the idea of functions and is instead purely a text substitution mechanism,
attempting to call a macro recursively such as shown above will replace the first instance of sum() with the text representation on the right. 
Then if such a function sum() is defined in another object file or library, it is invoked, otherwise an undefined error is thrown.

In this code, int sum(int a, int b) is defined in object file sum_impl.o and referenced in rec_macro.c as an extern function. 
Once the preprocessor parses the macro, the program at compile time will try to resolve sum(a,b) and use the implementation from sum_impl.c
