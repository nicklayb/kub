module View exposing (view)

import Browser exposing (Document)
import Html
import Model exposing (Model(..), Msg(..))
import Page
import Page.Game
import Page.Home



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
            render Page.Other (\_ -> Ignored) Page.viewNotFound

        Model.NotFound _ ->
            render Page.Other (\_ -> Ignored) Page.viewNotFound

        Model.Home home ->
            render Page.Home GotHomeMsg (Page.Home.view home)

        Model.Game game ->
            render Page.Game GotGameMsg (Page.Game.view game)
