module Model exposing (Model(..), Msg(..), init, update)

import Browser
import Browser.Navigation as Nav
import Flags exposing (FlagsInput)
import Html exposing (..)
import Html.Events exposing (..)
import Http exposing (Error(..))
import Page exposing (..)
import Page.Game as Game
import Page.Home as Home exposing (..)
import Route exposing (Route)
import Session exposing (..)
import Time exposing (..)
import Url



-- ---------------------------
-- MODEL
-- ---------------------------


type Model
    = NotFound Session
    | Redirect Session
    | Home Home.Model
    | Game Game.Model


init : FlagsInput -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flagsInput url key =
    let
        sessionData =
            flagsInput
                |> Flags.decode
                |> Flags.toSessionData
    in
    changeRouteTo (Route.fromUrl url) (Redirect (Session.init sessionData key))



-- ---------------------------
-- UPDATE
-- ---------------------------


type Msg
    = Ignored
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotHomeMsg Home.Msg
    | GotGameMsg Game.Msg
    | RedirectTo Route


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( Ignored, _ ) ->
            ( model, Cmd.none )

        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl (Session.navKey (toSession model)) (Url.toString url)
                    )

                Browser.External url ->
                    ( model, Nav.load url )

        ( UrlChanged url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( GotGameMsg subMsg, Game game ) ->
            Game.update subMsg game
                |> updateWith Game GotGameMsg model

        ( GotHomeMsg subMsg, Home home ) ->
            Home.update subMsg home
                |> updateWith Home GotHomeMsg model

        ( RedirectTo route, _ ) ->
            changeRouteTo (Just route) model

        ( _, _ ) ->
            ( model, Cmd.none )


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        session =
            toSession model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Nav.replaceUrl (Session.navKey session) (Route.routeToString Route.Home) )

        Just Route.Home ->
            Home.init session
                |> updateWith Home GotHomeMsg model

        Just Route.Game ->
            Game.init session
                |> updateWith Game GotGameMsg model


toSession : Model -> Session
toSession page =
    case page of
        NotFound session ->
            session

        Redirect session ->
            session

        Home home ->
            Home.toSession home

        Game game ->
            Game.toSession game


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg _ ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )
