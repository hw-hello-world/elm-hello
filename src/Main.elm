port module Main exposing (..)

import Html exposing (..)
import Html as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String
import Navigation
import Date

main : Program ProgramOptions Model Msg
main =
    Navigation.programWithFlags UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


--------------------------------------------------
-- MODEL
--------------------------------------------------

type alias ProgramOptions =
    { user : Maybe User
    }

type alias Model =
    { history : List Navigation.Location
    , user : Maybe User
    }


type alias User =
    { name : String
    }

type Msg
    = Welcome
    | UrlChange Navigation.Location

--------------------------------------------------
-- INIT
--------------------------------------------------

init : ProgramOptions -> Navigation.Location  -> (Model, Cmd Msg)
init opt location = (Model [ location ] opt.user, Cmd.none)


--------------------------------------------------
-- UPDATE
--------------------------------------------------

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Welcome ->
        ( model, Cmd.none )

    UrlChange location ->
        ( { model | history = location :: model.history }
        , Cmd.none
        )


--------------------------------------------------
-- VIEW
--------------------------------------------------

view : Model -> Html Msg
view model =
    case List.head model.history of
        Nothing -> homeView
        Just loc -> handleRouter model loc

handleRouter : Model -> Navigation.Location -> Html Msg
handleRouter model loc = if loc.pathname == "/page1" then page1View
                   else if loc.pathname == "/page2" then page2View
                   else homeView

homeView : Html Msg
homeView =
    ul [ ]
        [ li []
              [ a [ href "/page1" ]
                    [ text "Page 1" ]
              ]
        , li []
              [ a [ href "/page2" ]
                    [ text "Page 2" ]
              ]
        ]

page1View : Html Msg
page1View = h1 [] [text "Welcome to Page 1"]

page2View : Html Msg
page2View = h1 [] [text "Welcome to Page 2"]  -- FIXME: after page render, send an message to JS.


--------------------------------------------------
-- PORTs
--------------------------------------------------

port welcome : () -> Cmd msg
