module Flags exposing (Flags, FlagsInput, decode, toSessionData)

import Json.Decode exposing (Decoder)
import Kub.Grid as Grid exposing (Grid)
import Session exposing (SessionData)


type alias FlagsInput =
    Json.Decode.Value


type alias Flags =
    { timestamp : Int
    , savedGame : Maybe Grid
    }


defaultFlags : Flags
defaultFlags =
    { savedGame = Nothing
    , timestamp = 0
    }


gridDecoder : Decoder (Maybe Grid)
gridDecoder =
    let
        requireNonEmpty list =
            case list of
                Just [ [] ] ->
                    Json.Decode.succeed Nothing

                Just _ ->
                    Json.Decode.succeed list

                Nothing ->
                    Json.Decode.succeed Nothing
    in
    Grid.decoder
        |> Json.Decode.maybe
        |> Json.Decode.andThen requireNonEmpty


decoder : Decoder Flags
decoder =
    Json.Decode.map2 Flags
        (Json.Decode.field "timestamp" Json.Decode.int)
        (Json.Decode.field "grid" gridDecoder)


decode : FlagsInput -> Flags
decode input =
    input
        |> Json.Decode.decodeValue decoder
        |> Result.withDefault defaultFlags


toSessionData : Flags -> SessionData
toSessionData flags =
    let
        newGrid =
            Grid.init Grid.size flags.timestamp
    in
    case flags.savedGame of
        Just grid ->
            { grid = grid, timestamp = flags.timestamp }

        Nothing ->
            { grid = newGrid, timestamp = flags.timestamp }
