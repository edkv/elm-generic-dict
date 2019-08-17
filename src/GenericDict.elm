module GenericDict exposing
    ( Dict
    , diff
    , empty
    , filter
    , foldl
    , foldr
    , fromList
    , get
    , insert
    , intersect
    , isEmpty
    , keys
    , map
    , member
    , merge
    , partition
    , remove
    , singleton
    , size
    , toList
    , union
    , update
    , values
    )

import Dict


type Dict k v
    = Dict (Dict.Dict String ( k, v ))


empty : Dict k v
empty =
    Dict Dict.empty


singleton : (k -> String) -> k -> v -> Dict k v
singleton toString key value =
    Dict (Dict.singleton (toString key) ( key, value ))


insert : (k -> String) -> k -> v -> Dict k v -> Dict k v
insert toString key value (Dict dict) =
    Dict (Dict.insert (toString key) ( key, value ) dict)


update : (k -> String) -> k -> (Maybe v -> Maybe v) -> Dict k v -> Dict k v
update toString key fn (Dict dict) =
    Dict (Dict.update (toString key) (Maybe.map Tuple.second >> fn >> Maybe.map (Tuple.pair key)) dict)


remove : (k -> String) -> k -> Dict k v -> Dict k v
remove toString key (Dict dict) =
    Dict (Dict.remove (toString key) dict)


isEmpty : Dict k v -> Bool
isEmpty (Dict dict) =
    Dict.isEmpty dict


member : (k -> String) -> k -> Dict k v -> Bool
member toString key (Dict dict) =
    Dict.member (toString key) dict


get : (k -> String) -> k -> Dict k v -> Maybe v
get toString key (Dict dict) =
    Dict.get (toString key) dict |> Maybe.map Tuple.second


size : Dict k v -> Int
size (Dict dict) =
    Dict.size dict


keys : Dict k v -> List k
keys =
    foldr (\key value -> (::) key) []


values : Dict k v -> List v
values =
    foldr (\key value -> (::) value) []


toList : Dict k v -> List ( k, v )
toList (Dict dict) =
    Dict.values dict


fromList : (k -> String) -> List ( k, v ) -> Dict k v
fromList toString =
    List.foldl (\( key, value ) -> insert toString key value) empty


map : (k -> a -> b) -> Dict k a -> Dict k b
map fn (Dict dict) =
    Dict (Dict.map (\_ ( key, value ) -> ( key, fn key value )) dict)


foldl : (k -> v -> b -> b) -> b -> Dict k v -> b
foldl fn acc (Dict dict) =
    Dict.foldl (\_ ( key, value ) -> fn key value) acc dict


foldr : (k -> v -> b -> b) -> b -> Dict k v -> b
foldr fn acc (Dict dict) =
    Dict.foldr (\_ ( key, value ) -> fn key value) acc dict


filter : (k -> v -> Bool) -> Dict k v -> Dict k v
filter fn (Dict dict) =
    Dict (Dict.filter (\_ ( key, value ) -> fn key value) dict)


partition : (k -> v -> Bool) -> Dict k v -> ( Dict k v, Dict k v )
partition fn (Dict dict) =
    Dict.partition (\_ ( key, value ) -> fn key value) dict |> Tuple.mapBoth Dict Dict


union : Dict k v -> Dict k v -> Dict k v
union (Dict dict1) (Dict dict2) =
    Dict (Dict.union dict1 dict2)


intersect : Dict k v -> Dict k v -> Dict k v
intersect (Dict dict1) (Dict dict2) =
    Dict (Dict.intersect dict1 dict2)


diff : Dict k v -> Dict k v -> Dict k v
diff (Dict dict1) (Dict dict2) =
    Dict (Dict.diff dict1 dict2)


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
