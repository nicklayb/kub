module Main exposing (main, view)

import Browser exposing (Document)
import Flags exposing (FlagsInput)
import Html exposing (..)
import Html.Events exposing (..)
import Http exposing (Error(..))
import Page exposing (..)
import Model exposing (Model(..), Msg(..))
import Page.Game
import Page.Home
import Session exposing (..)
import Time exposing (..)



-- ---------------------------
-- VIEW
-- ---------------------------


view : Model -> Document Msg
view model =
    let
        render page toMsg config =
            let
                { title, body } =
                    Page.view page config
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model of
        Model.Redirect _ ->
            render Page.Other (\_ -> Ignored) viewNotFound

        Model.NotFound _ ->
            render Page.Other (\_ -> Ignored) viewNotFound

        Model.Home home ->
            render Page.Home GotHomeMsg (Page.Home.view home)

        Model.Game game ->
            render Page.Game GotGameMsg (Page.Game.view game)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- ---------------------------
-- MAIN
-- ---------------------------


main : Program FlagsInput Model Msg
main =
    Browser.application
        { init = Model.init
        , update = Model.update
        , view = view
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
