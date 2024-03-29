port module Page.Game exposing (Model, Msg, init, toSession, update, view)

import Html exposing (..)
import Html.Attributes exposing (class, href, style)
import Html.Events exposing (onClick)
import Json.Encode
import Kub.Grid as Grid exposing (..)
import Kub.Merge as Merge exposing (..)
import Page exposing (PageDefinition)
import Process exposing (..)
import Session exposing (..)
import Task exposing (..)
import Utils exposing (..)


port persistGame : Json.Encode.Value -> Cmd msg


type State
    = Playing
    | Falling


type alias Model =
    { session : Session
    , grid : Grid
    , selected : List Coord
    , state : State
    , lastColor : Maybe Cell
    }


type Msg
    = CellClick Coord
    | FallGrid


type Count
    = Count Cell Int


init : Session -> ( Model, Cmd Msg )
init session =
    let
        sessionGrid =
            case session of
                Guest _ { grid } ->
                    grid
    in
    ( { session = session
      , grid = sessionGrid
      , selected = []
      , state = Playing
      , lastColor = Nothing
      }
    , Cmd.none
    )


view : Model -> PageDefinition Msg
view model =
    { title = "K  U  B"
    , content =
        div [ class "flex wrapper" ]
            [ gridView model
            , statsView model
            ]
    }


gridBorder : Maybe Cell -> String
gridBorder =
    Utils.stringMaybe toText


statsView : Model -> Html Msg
statsView model =
    let
        defaultStats =
            [ ( "Remaining", totalText model )
            ]

        appends =
            [ div [ class "stats" ] [ viewProgress model.grid ]
            , div [ class "stats" ] [ a [ href "https://nboisvert.com" ] [ text "Website" ] ]
            ]
    in
    div [ class "flex stats-box row" ]
        (List.map statText (List.append defaultStats (colorCounters model)) ++ appends)


colorCounters : Model -> List ( String, String )
colorCounters model =
    let
        calculateColor color =
            ( toText color, String.fromInt (Grid.countCell color model.grid) )
    in
    List.map calculateColor Grid.asList


totalText : Model -> String
totalText { grid } =
    let
        count =
            Grid.count grid

        total =
            Grid.sizeOfTotal grid
    in
    String.fromInt count ++ " (" ++ percentText count total ++ ")"


ratios : Grid -> List Count
ratios grid =
    let
        calculateRatio color =
            Count color (Grid.countCell color grid)
    in
    List.map calculateRatio Grid.asList


viewProgress : Grid -> Html Msg
viewProgress grid =
    let
        gridRatios =
            ratios grid

        ratioBar (Count color count) =
            let
                total =
                    Grid.sizeOfTotal grid

                percent =
                    String.fromInt ((100 * count) // total) ++ "%"
            in
            span [ class (Grid.toText color), style "width" percent ] []
    in
    div [ class "progress" ] (List.map ratioBar gridRatios)


statText : ( String, String ) -> Html Msg
statText ( label, value ) =
    div [ class "stats" ]
        [ span [ class "stats-label" ] [ text (label ++ ": ") ]
        , span [ class "stats-value" ] [ text value ]
        ]


percentText : Int -> Int -> String
percentText count total =
    String.fromInt (((total - count) * 100) // total) ++ "%"


gridView : Model -> Html Msg
gridView { grid, selected, lastColor } =
    let
        renderCell rowIndex columnIndex cell =
            div [ class (cellClass ( rowIndex, columnIndex ) cell selected), onClick (CellClick ( rowIndex, columnIndex )) ] []

        renderRow rowIndex row =
            div [ class "flex row" ] (List.indexedMap (renderCell rowIndex) row)
    in
    div [ class ("flex column grid " ++ ("border-" ++ gridBorder lastColor)) ] (List.indexedMap renderRow grid)


cellClass : Coord -> Maybe Cell -> List Coord -> String
cellClass coord cell selected =
    let
        isSelected =
            Utils.stringIf "selected" (List.member coord selected)

        asText =
            case cell of
                Just color ->
                    toText color

                Nothing ->
                    "empty"
    in
    String.join " " [ "flex", "column", "cell", asText, isSelected ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CellClick coord ->
            case model.state of
                Playing ->
                    handleClick coord model

                Falling ->
                    ( model, Cmd.none )

        FallGrid ->
            let
                fallenModel =
                    fallGrid model
            in
            ( fallenModel, saveGame fallenModel )


handleClick : Coord -> Model -> ( Model, Cmd Msg )
handleClick coord model =
    if List.member coord model.selected && List.length model.selected > 1 then
        ( model
            |> updateLastColor coord
            |> removeSelected
        , dispatchFall
        )

    else
        ( setSelected coord model, Cmd.none )


dispatchFall : Cmd Msg
dispatchFall =
    Process.sleep 300
        |> Task.andThen Task.succeed
        |> Task.perform (\_ -> FallGrid)


removeSelected : Model -> Model
removeSelected model =
    { model
        | grid = Merge.remove model.selected model.grid
        , selected = []
        , state = Falling
    }


updateLastColor : Coord -> Model -> Model
updateLastColor coord model =
    { model | lastColor = getAt coord model.grid }


fallGrid : Model -> Model
fallGrid model =
    { model | grid = Merge.fallDown model.grid, state = Playing }


setSelected : Coord -> Model -> Model
setSelected coord model =
    let
        getSiblings =
            Merge.siblingsOf coord model.grid
    in
    Utils.updateIf (\m -> { m | selected = getSiblings }) model (List.length getSiblings > 1)


toSession : Model -> Session
toSession { session } =
    session


saveGame : Model -> Cmd msg
saveGame { grid } =
    persistGame <| Grid.encode grid
