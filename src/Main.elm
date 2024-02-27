module Main exposing (main)

import Browser
import Flags exposing (FlagsInput)
import Model exposing (Model, Msg(..))
import View


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
        , view = View.view
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
