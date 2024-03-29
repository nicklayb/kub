module Kub.Grid exposing (Cell(..), Coord, Grid, Size, asList, decoder, columnIndexOf, count, countCell, fold, getAt, heightOf, init, isSame, map, mergeAt, randomGrid, rowIndexOf, setAllAt, setAt, size, sizeOf, sizeOfTotal, toKey, toText, widthOf, encode)

import Array exposing (..)
import Json.Encode
import Json.Decode exposing (Decoder)
import Random exposing (..)
import Utils


type alias Grid =
    List (List (Maybe Cell))


type Cell
    = Red
    | Green
    | Blue
    | Yellow


type alias Size =
    ( Int, Int )


type alias Coord =
    Size


size : Size
size =
    ( 20, 12 )


asList : List Cell
asList =
    [ Red
    , Green
    , Blue
    , Yellow
    ]


redString : String
redString =
    "red"

blueString : String
blueString =
    "blue"

greenString : String
greenString =
    "green"

yellowString : String
yellowString =
    "yellow"


cellFromString : String -> Maybe Cell
cellFromString string =
    if string == redString then
        Just Red
    else if string == greenString then
        Just Green
    else if string == blueString then
        Just Blue
    else if string == yellowString then
        Just Yellow
    else
        Nothing

cellToString : Cell -> String
cellToString cell =
    case cell of
        Red -> redString
        Blue -> blueString
        Green -> greenString
        Yellow -> yellowString

cellDecoder : Decoder Cell
cellDecoder =
    let
        itemDecoder string = 
            case cellFromString string of
                Just cell ->
                    Json.Decode.succeed cell

                    
                Nothing ->
                    Json.Decode.fail "Invalid cell value"
    in
    Json.Decode.string
        |> Json.Decode.andThen itemDecoder

decoder : Decoder Grid
decoder =
    Json.Decode.list (Json.Decode.list (Json.Decode.nullable cellDecoder))

cellEncoder : Maybe Cell -> Json.Encode.Value
cellEncoder maybeCell =
    case maybeCell of
        Just cell ->
            Json.Encode.string (cellToString cell)

        _ ->
            Json.Encode.null

encode : Grid -> Json.Encode.Value
encode grid =
    (Json.Encode.list (Json.Encode.list cellEncoder)) grid


getAt : Coord -> Grid -> Maybe Cell
getAt ( rowIndex, columnIndex ) grid =
    Array.get rowIndex (fromList grid)
        |> Maybe.andThen (\row -> Array.get columnIndex (fromList row))
        |> Maybe.andThen identity


setAt : Maybe Cell -> Coord -> Grid -> Grid
setAt cell coord grid =
    let
        setCell ( currentCoord, currentCell ) =
            if coord == currentCoord then
                cell

            else
                currentCell
    in
    map setCell grid


setAllAt : Maybe Cell -> List Coord -> Grid -> Grid
setAllAt cell coords grid =
    let
        setCell ( currentCoord, currentCell ) =
            if List.member currentCoord coords then
                cell

            else
                currentCell
    in
    map setCell grid


map : (( Coord, Maybe Cell ) -> Maybe Cell) -> Grid -> Grid
map func =
    let
        inCell row column cell =
            func ( ( row, column ), cell )

        inRow index row =
            List.indexedMap (inCell index) row
    in
    List.indexedMap inRow


isSame : Cell -> Cell -> Bool
isSame first second =
    toText first == toText second


toText : Cell -> String
toText cell =
    case cell of
        Red ->
            "red"

        Green ->
            "green"

        Blue ->
            "blue"

        Yellow ->
            "yellow"


toKey : Cell -> String
toKey cell =
    String.left 1 (toText cell)


widthOf : Grid -> Int
widthOf grid =
    case grid of
        [] ->
            0

        h :: _ ->
            List.length h


fold : (Maybe Cell -> b -> b) -> b -> Grid -> b
fold func initial grid =
    let
        inRow row acc =
            List.foldl func acc row
    in
    List.foldl inRow initial grid


count : Grid -> Int
count grid =
    fold (\cell acc -> Utils.updateMaybe ((+) 1) acc cell) 0 grid


countCell : Cell -> Grid -> Int
countCell checkCell grid =
    let
        countJustCell cell acc =
            case cell of
                Nothing ->
                    acc

                Just c ->
                    Utils.updateIf ((+) 1) acc (isSame c checkCell)
    in
    fold countJustCell 0 grid


heightOf : Grid -> Int
heightOf grid =
    List.length grid


sizeOf : Grid -> Size
sizeOf grid =
    ( widthOf grid, heightOf grid )


sizeOfTotal : Grid -> Int
sizeOfTotal grid =
    let
        total ( w, h ) =
            w * h
    in
    total (sizeOf grid)


rowIndexOf : Coord -> Int
rowIndexOf ( row, _ ) =
    row


columnIndexOf : Coord -> Int
columnIndexOf ( _, column ) =
    column


randomGrid : Size -> Int -> Grid
randomGrid s seed =
    let
        generator ( width, height ) =
            Random.list height (Random.list width cell)

        cell =
            Random.uniform (Just Red)
                [ Just Green
                , Just Blue
                , Just Yellow
                ]
    in
    Tuple.first (Random.step (generator s) (initialSeed seed))


mergeAt : Coord -> Grid -> Grid
mergeAt _ grid =
    grid


init : Size -> Int -> Grid
init =
    randomGrid
