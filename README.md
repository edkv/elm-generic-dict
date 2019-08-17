# GenericDict

A wrapper over `Dict` from `elm/core` that allows you to use any types as keys.

Unlike existing solutions, doesn't store functions in the data structure and
doesn't have any performance implications (except slightly higher memory usage
because it stores both original keys and their stringified versions), but requires
you to explicitly pass a `key -> String` function that tells how to convert your
key type to a `String` to all functions that need it.


## Other differences from `elm/core`

The standard `Dict` sorts key-value pairs in the order of keys. In this library
key-value pairs are sorted by stringified versions of keys. But with non-comparable
types that are just converted to `String`, thinking about the order doesn't make
that much sense. So the idea is that you should consider the order an implementation
detail and shouldn't rely on it when using functions like `keys` and `values`.
And because of this, instead of having `foldl` and `foldr`, this library exposes
only one function, which is named `fold`.


## Example

```elm
module User exposing (Id, User, new, idFromString, idToString)


-- In reality I would use custom types for `name`, `email`, and `age`.
-- And I would also add checks for `Id` format!


type Id
    = Id String


type User
    = User
        { name : String
        , email : String
        , age : Int
        }


new : 
    { name : String
    , email : String
    , age : Int
    }
    -> User
new =
    User


idFromString : String -> Id
idFromString =
    Id


idToString : Id -> String
idToString (Id string) =
    string
```

```elm
module Data exposing (users)

import User exposing (User)
import GenericDict as Dict exposing (Dict)


users : Dict User.Id User
users =
    Dict.fromList User.idToString
        [ ( User.idFromString "ef5f03aa-30d8-41fa-9730-9074daffbfd2" 
          , User.new
              { name = "Bob"
              , email = "bob@example.com"
              , age = 25
              }
          )
        , ( User.idFromString "b6c87ad8-d8b8-4f91-a680-6fec7c1aefb6" 
          , User.new
              { name = "Alice"
              , email = "alice@example.com"
              , age = 22
              }
          )
        , ( User.idFromString "3a84502a-2423-4168-9f5e-1b5fe8eff034" 
          , User.new
              { name = "Chuck"
              , email = "chuck@example.com"
              , age = 30
              }
          )
        ]
```

```elm
-- Get a user
Dict.get User.idToString id Data.users

-- Add a new user
Dict.insert
    User.idToString
    id
    (User.new { name = "Eve", email = "eve@example.com", age = 26 })
    Data.users

-- Remove a user
Dict.remove User.idToString id Data.users
```
