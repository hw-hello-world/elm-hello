port module Main exposing (..)

import Html exposing (..)
import Html as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String
import Navigation
import Date
import Json.Decode as Decode
import Http

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
    , metadata : Maybe Metadata
    }


type alias User =
    { name : String
    }

type Msg
    = Welcome
    | UrlChange Navigation.Location
    | LoadMetadata (Result Http.Error Metadata)

--------------------------------------------------
-- INIT
--------------------------------------------------

init : ProgramOptions -> Navigation.Location  -> (Model, Cmd Msg)
init opt location = (Model [ location ] opt.user Nothing, send)


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

    LoadMetadata (Ok meta) -> ({ model | metadata = Just meta}, Cmd.none)
    LoadMetadata (Err _) -> ({ model | metadata = Nothing}, Cmd.none)


getMetadata : Http.Request Metadata
getMetadata =
    Http.get "https://jsonplaceholder.typicode.com/posts/1" decodeMetadata

type alias Metadata =
    { body : String
    , postId : Int
    , title : String
    }

decodeMetadata : Decode.Decoder Metadata
decodeMetadata =
  Decode.map3 Metadata
    (Decode.field "body" Decode.string)
    (Decode.field "id" Decode.int)
    (Decode.field "title" Decode.string)

send : Cmd Msg
send =
  Http.send LoadMetadata getMetadata

--------------------------------------------------
-- VIEW
--------------------------------------------------

view : Model -> Html Msg
view model =
    case List.head model.history of
        Nothing -> homeView model
        Just loc -> handleRouter model loc

handleRouter : Model -> Navigation.Location -> Html Msg
handleRouter model loc = if loc.hash == "#page1" then page1View
                   else if loc.hash == "#page2" then page2View
                   else homeView model

homeView : Model -> Html Msg
homeView m =
    div []
        [
         ul [ ]
             [ li []
                   [ a [ href "#page1" ]
                         [ text "Page 1" ]
                   ]
             , li []
                 [ a [ href "#page2" ]
                       [ text "Page 2" ]
              ]
             ]
        , div []
            (case m.metadata of
                 Just md -> [ label [] [text "Title:"]
                            , p [] [ text md.title ]
                            , label [] [text "Body:"]
                            , p [] [ text md.body]
                            ]
                 Nothing -> []
            )
        ]


page1View : Html Msg
page1View = h1 [] [text "Welcome to Page 1"]

page2View : Html Msg
page2View = h1 [] [text "Welcome to Page 2"]


--------------------------------------------------
-- PORTs
--------------------------------------------------

port welcome : () -> Cmd msg
