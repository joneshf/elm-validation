module Validation
    exposing
        ( append
        , appendNonempty
        )

{-|

## Useful functions

@docs append
@docs appendNonempty

## Example


```elm
-- We might imagine this as the inputs from our UI.
-- We can't trust that the user has entered the correct age and name.
type alias RawPerson =
  { name : String
  , age : Int
  }

-- We can describe the type of errors we might run into.
-- We keep track of the faulty values in the error.
type Error
  = InvalidName String
  | TooYoung Int
  | TooOld Int

-- We provide some distinct types so we know that if we have one of these,
-- it is not the same as the plain underlying type.
type Name
  = Name String

type Age
  = Age Int

-- Here we define what our actual person looks like.
-- The name and age are not just plain strings and ints, respectively.
-- This means it's _much_ harder to accidentally pass the wrong thing around.
-- It also means it's _much_ harder to replace these values on accident.
type alias Person =
  { name : Name
  , age : Age
  }

-- We can write a function to validate raw string input.
-- We might imagine a more thorough check.
validateName : String -> Result (Nonempty Error) Name
validateName str =
  if str == "bad word" then
      Err (InvalidName str)
  else
      Ok (Name str)

-- Here we can validate that an int is within a certain range
validateAge : Int -> Result (Nonempty Error) Age
validateAge n =
  if n < 35 then
      Err (TooYoung n)
  else if 45 < n then
      Err (TooOld n)
  else
      Ok (Age n)

-- Finally, we can validate the whole thing in one go.
validatePerson : RawPerson -> Result (Nonempty Error) Person
validatePerson person =
  map2 Person (validateName person.name) (validateAge person.age)
```
-}

import List.Nonempty exposing (Nonempty)


{-| Accumulate errors in a nonempty list.

Useful when you want to combine two validations together and get all of the errors.

We use a nonempty list because it doesn't make sense to have `Err []`.
What does an empty list mean here?
Does it mean there was a programmer error and some function far away is at fault?
Does it mean there was an "unknown error"?
Whatever the meaning is lost and you have to find the provenance by looking at every function you've used.
Rather, if you want to encode the idea of an unknown error, you should add that to your error type.
Then, we can know by construction that all the errors are valid, and we also have more confidence about what an error means.

This is different from attempting to validate with `Result a b`.
With this `Result (Nonempty a) b`, _all_ of the `a`s are accumulated if any exist.
With `Result a b`, we'd only get the first `a` if any exist.

Both have their uses, neither is better than the other.
-}
appendNonempty :
    (a -> b -> c)
    -> Result (Nonempty d) a
    -> Result (Nonempty d) b
    -> Result (Nonempty d) c
appendNonempty f x y =
    case ( x, y ) of
        ( Err xs, Err ys ) ->
            Err (List.Nonempty.append xs ys)

        ( Err xs, _ ) ->
            Err xs

        ( _, Err ys ) ->
            Err ys

        ( Ok a, Ok b ) ->
            Ok (f a b)


{-| Accumulate validations in an `appendable`.

This function allows you to work with the wonderful [elm-verify][].

[elm-verify][] provides combinators for creating validations
and a number of functions that work well in pipeline style.

If you've built up a validation using [elm-verify][],
you can append them together using this function.

[elm-verify]: http://package.elm-lang.org/packages/stoeffel/elm-verify/latest

-}
append :
    (a -> b -> c)
    -> Result appendable a
    -> Result appendable b
    -> Result appendable c
append f x y =
    case ( x, y ) of
        ( Err xs, Err ys ) ->
            Err (xs ++ ys)

        ( Err xs, _ ) ->
            Err xs

        ( _, Err ys ) ->
            Err ys

        ( Ok a, Ok b ) ->
            Ok (f a b)
