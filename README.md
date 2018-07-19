# elm-validation

Applicative validation in elm

## Motivation

There is a very nice pattern for validating data: data is either some set of errors or a validated value.
This pattern has shown up for years in multiple different places:

* <https://pursuit.purescript.org/packages/purescript-validation/3.2.0/docs/Data.Validation.Semigroup>
* <https://github.com/ms-ati/rumonade/wiki/Applicative-Validation-in-Ruby>
* <https://hackage.haskell.org/package/validation-0.6.2/docs/Data-Validation.html>
* <https://www.npmjs.com/package/applicative.validation>
* <https://brianmckenna.org/blog/applicative_validation_js>
* <https://github.com/csierra/java-functional-applicative-validation>
* <https://ro-che.info/articles/2015-05-02-smarter-validation>
* <https://datasciencevademecum.wordpress.com/2016/03/09/functional-data-validation-using-monads-and-applicative-functors/>
* <https://codurance.com/2017/11/30/applicatives-validation/>

You can translate these ideas directly into elm,
but you end up making something that doesn't fit well with the rest of the ecosystem.

What we can do instead, is take the inspiration for this idea and translate it to more idomatic elm.
Which is to say, don't forget where the idea came from, and don't shy away from the terminology, but also don't try to reinvent the wheel.

## How's it work?

The basic idea is that you want to return a union of possible states.
Inspired by such phrases as ["Make illegal states unrepresentable"][Make illegal state unrepresentable] and ["Making impossible states impossible"][Making impossible states impossible] we can encode this idea of "a validated value or an accumulation of errors" into a data type.

Lucky us, we already have a data type that represents success and failure: `Result a b`.

Since the `a` in `Result a b` is polymorphic, we can replace it with something specific to our problem: `Result (Nonempty a) b`.
And we're done!
Regular old type level composition has allowed us to make illegal states unrepresentable.
If you have an `Err x`, you have at least one error to deal with.
If you have an `Ok x`, you have a valid thing.

We've encoded the idea that validation is either some failure — `Nonempty a` — or a success — `b`.
The `Nonempty a` allows us to accumulate all of the errors we've seen.

Notice what we didn't do:
* We didn't define a completely new distinct type.

    We could give it an alias if we wanted, or someone else could.
    elm doesn't have things like interfaces or type classes.
    Attempting to emulate them here makes for a more complex situation without getting many of the advantages those features give.

* We didn't put the onus on you to ensure you ran validations.

    Assuming you type things well, you _can't_ forget to validate data.
    It won't compile if you don't validate it.

* We didn't mix concerns.

    You can think about errors completely separately from validated values.
    When you're casing, you only have to process one side at a time.
    A failure case _only has the errors_.
    A successful case _only has the successful value_.
    
    If **you** decide that your error cases also have what can be considered a successful value,
    you're more than free to do so.
    This package does not make that choice for you, but you're still free to make that.

But notice what we get, we can still keep all of the functions that exist in the rest of the ecosystem.
If you want to use `Result.Extra.combine` with this validation package, you can do that with no overhead!

## What does this package provide?

If it's so simple, why does this package exist?
This package provides one function to accumulate failures.
We intentionally make very few choices about how to deal with validation so it's easier/more straight forward/whatever to use with other packages.

[Make illegal state unrepresentable]: https://blog.janestreet.com/effective-ml-revisited/#make-illegal-states-unrepresentable
[Making impossible states impossible]: https://youtu.be/IcgmSRJHu_8
