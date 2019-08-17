module GenericDict exposing
    ( Dict
    , empty, singleton, insert, update, remove
    , isEmpty, member, get, size
    , keys, values, toList, fromList
    , map, fold, filter, partition
    , union, intersect, diff, merge
    )

{-|

@docs Dict


# Build

@docs empty, singleton, insert, update, remove


# Query

@docs isEmpty, member, get, size


# Lists

@docs keys, values, toList, fromList


# Transform

@docs map, fold, filter, partition


# Combine

@docs union, intersect, diff, merge

-}

import Dict


{-| A dictionary of keys and values. Keys can be any type.
-}
type Dict k v
    = Dict (Dict.Dict String ( k, v ))


{-| Create an empty dictionary.
-}
empty : Dict k v
empty =
    Dict Dict.empty


{-| Create a dictionary with one key-value pair.
-}
singleton : (k -> String) -> k -> v -> Dict k v
singleton toString key value =
    Dict (Dict.singleton (toString key) ( key, value ))


{-| Insert a key-value pair into a dictionary. Replaces value when there is a collision.
-}
insert : (k -> String) -> k -> v -> Dict k v -> Dict k v
insert toString key value (Dict dict) =
    Dict (Dict.insert (toString key) ( key, value ) dict)


{-| Update the value of a dictionary for a specific key with a given function.
-}
update : (k -> String) -> k -> (Maybe v -> Maybe v) -> Dict k v -> Dict k v
update toString key fn (Dict dict) =
    Dict (Dict.update (toString key) (Maybe.map Tuple.second >> fn >> Maybe.map (Tuple.pair key)) dict)


{-| Remove a key-value pair from a dictionary. If the key is not found, no changes are made.
-}
remove : (k -> String) -> k -> Dict k v -> Dict k v
remove toString key (Dict dict) =
    Dict (Dict.remove (toString key) dict)


{-| Determine if a dictionary is empty.
-}
isEmpty : Dict k v -> Bool
isEmpty (Dict dict) =
    Dict.isEmpty dict


{-| Determine if a key is in a dictionary.
-}
member : (k -> String) -> k -> Dict k v -> Bool
member toString key (Dict dict) =
    Dict.member (toString key) dict


{-| Get the value associated with a key. Returns `Nothing` if the key is not found.
-}
get : (k -> String) -> k -> Dict k v -> Maybe v
get toString key (Dict dict) =
    Dict.get (toString key) dict |> Maybe.map Tuple.second


{-| Determine the number of key-value pairs in the dictionary.
-}
size : Dict k v -> Int
size (Dict dict) =
    Dict.size dict


{-| Get all of the keys in a dictionary.
-}
keys : Dict k v -> List k
keys (Dict dict) =
    Dict.foldr (\_ ( key, _ ) -> (::) key) [] dict


{-| Get all of the values in a dictionary.
-}
values : Dict k v -> List v
values (Dict dict) =
    Dict.foldr (\_ ( _, value ) -> (::) value) [] dict


{-| Convert a dictionary into an association list of key-value pairs.
-}
toList : Dict k v -> List ( k, v )
toList (Dict dict) =
    Dict.values dict


{-| Convert an association list into a dictionary.
-}
fromList : (k -> String) -> List ( k, v ) -> Dict k v
fromList toString =
    List.foldl (\( key, value ) -> insert toString key value) empty


{-| Apply a function to all values in a dictionary.
-}
map : (k -> a -> b) -> Dict k a -> Dict k b
map fn (Dict dict) =
    Dict (Dict.map (\_ ( key, value ) -> ( key, fn key value )) dict)


{-| Fold over the key-value pairs in a dictionary.
-}
fold : (k -> v -> b -> b) -> b -> Dict k v -> b
fold fn acc (Dict dict) =
    Dict.foldl (\_ ( key, value ) -> fn key value) acc dict


{-| Keep only the key-value pairs that pass the given test.
-}
filter : (k -> v -> Bool) -> Dict k v -> Dict k v
filter fn (Dict dict) =
    Dict (Dict.filter (\_ ( key, value ) -> fn key value) dict)


{-| Partition a dictionary according to some test. The first dictionary contains all
key-value pairs which passed the test, and the second contains the pairs that did not.
-}
partition : (k -> v -> Bool) -> Dict k v -> ( Dict k v, Dict k v )
partition fn (Dict dict) =
    Dict.partition (\_ ( key, value ) -> fn key value) dict |> Tuple.mapBoth Dict Dict


{-| Combine two dictionaries.
If there is a collision, preference is given to the first dictionary.
-}
union : Dict k v -> Dict k v -> Dict k v
union (Dict dict1) (Dict dict2) =
    Dict (Dict.union dict1 dict2)


{-| Keep a key-value pair when its key appears in the second dictionary.
Preference is given to values in the first dictionary.
-}
intersect : Dict k v -> Dict k v -> Dict k v
intersect (Dict dict1) (Dict dict2) =
    Dict (Dict.intersect dict1 dict2)


{-| Keep a key-value pair when its key does not appear in the second dictionary.
-}
diff : Dict k v -> Dict k v -> Dict k v
diff (Dict dict1) (Dict dict2) =
    Dict (Dict.diff dict1 dict2)


{-| The most general way of combining two dictionaries. You provide three
accumulators for when a given key appears:

1.  Only in the left dictionary.
2.  In both dictionaries.
3.  Only in the right dictionary.

You then traverse all the keys from lowest to highest, building up whatever you want.

-}
merge :
    (k -> a -> result -> result)
    -> (k -> a -> b -> result -> result)
    -> (k -> b -> result -> result)
    -> Dict k a
    -> Dict k b
    -> result
    -> result
merge fnLeft fnBoth fnRight (Dict dictLeft) (Dict dictRight) =
    Dict.merge
        (\_ ( key, value ) -> fnLeft key value)
        (\_ ( key, valueLeft ) ( _, valueRight ) -> fnBoth key valueLeft valueRight)
        (\_ ( key, value ) -> fnRight key value)
        dictLeft
        dictRight
