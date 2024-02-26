module Session exposing (Session(..), SessionData, init, navKey)

import Browser.Navigation as Nav
import Kub.Grid exposing (Grid)

type alias SessionData =
    { grid : Grid
    , timestamp : Int
    }

type Session
    = Guest Nav.Key SessionData


navKey : Session -> Nav.Key
navKey session =
    case session of
        Guest key _ ->
            key


init : SessionData -> Nav.Key -> Session
init sessionData key =
    Guest key sessionData
