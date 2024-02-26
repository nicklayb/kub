module Page.Home exposing (Model, Msg, init, toSession, update, view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Page exposing (PageDefinition)
import Route exposing (href)
import Session exposing (..)
import Utils exposing (..)


type alias Model =
    { session : Session
    }


type Msg
    = Noop


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session
      }
    , Cmd.none
    )


view : Model -> PageDefinition Msg
view _ =
    { title = "Home"
    , content =
        div [ class "flex jc-center ai-center" ]
            [ div [] [ a [ href Route.Game, class "start" ] [ text "start" ] ]
            ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            (model, Cmd.none)

toSession : Model -> Session
toSession model =
    model.session
