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

main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


--------------------------------------------------
-- MODEL
--------------------------------------------------


type alias Model =
    { history : List Navigation.Location
    , metadata : Maybe Metadata
    , users : List User
    }


type Msg
    = Welcome
    | UrlChange Navigation.Location
    | LoadMetadata (Result Http.Error Metadata)
    | GetUsers (Result Http.Error (List User))

--------------------------------------------------
-- INIT
--------------------------------------------------

init : Navigation.Location  -> (Model, Cmd Msg)
init location = (Model [ location ] Nothing [], Cmd.none)


--------------------------------------------------
-- UPDATE
--------------------------------------------------

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Welcome ->
        ( model, Cmd.none )

    -- FIXME: how to respond both click and page reload event in order to load user list??
    UrlChange location ->
        ( { model | history = location :: model.history }
        , (if location.hash == "#users" then getUsers else welcome location.hash)
        )

    LoadMetadata (Ok meta) -> ({ model | metadata = Just meta}, Cmd.none)
    LoadMetadata (Err _) -> ({ model | metadata = Nothing}, Cmd.none)
    GetUsers (Ok users) -> ({ model | users = users}, Cmd.none)
    GetUsers (Err _) -> ({ model | users = []}, Cmd.none)


type alias User =
    { id : String
    , status : String
    }
getUsersReq : Http.Request (List User)
getUsersReq = Http.get "/api/v1/users" decodeUser

decodeUser : Decode.Decoder (List User)
decodeUser = Decode.list (Decode.map2 User
             (Decode.field "id" Decode.string)
             (Decode.field "status" Decode.string))

getUsers : Cmd Msg
getUsers = Http.send GetUsers getUsersReq

type alias Metadata =
    { body : String
    , postId : Int
    , title : String
    }


getMetadataReq : Http.Request Metadata
getMetadataReq =
    Http.get "https://jsonplaceholder.typicode.com/posts/1" decodeMetadata

decodeMetadata : Decode.Decoder Metadata
decodeMetadata =
  Decode.map3 Metadata
    (Decode.field "body" Decode.string)
    (Decode.field "id" Decode.int)
    (Decode.field "title" Decode.string)

getMetadata : Cmd Msg
getMetadata =
  Http.send LoadMetadata getMetadataReq

--------------------------------------------------
-- VIEW
--------------------------------------------------

view : Model -> Html Msg
view model =
    case List.head model.history of
        Nothing -> homeView model
        Just loc -> handleRouter model loc

handleRouter : Model -> Navigation.Location -> Html Msg
handleRouter model loc = if loc.hash == "#users" then usersPageView model
                   else if loc.hash == "#page2" then page2View
                   else homeView model

homeView : Model -> Html Msg
homeView m =
    div []
        [
         ul [ ]
             [ li []
                   [ a [ href "#users" ]
                         [ text "Users" ]
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
        , userListView m
        ]

userListView : Model -> Html Msg
userListView m = case m.users of
                     [] -> div [] []
                     us -> ul [] (List.map userView us)

userView : User -> Html Msg
userView u = li [] [ text u.id, text " => ", text u.status ]

usersPageView : Model -> Html Msg
usersPageView m = div []
                  [ h1 [] [ text "Welcome to Users page"]
                  , userListView m
                  ]

page2View : Html Msg
page2View = h1 [] [text "Welcome to Page 2"]


--------------------------------------------------
-- PORTs
--------------------------------------------------

port welcome : String -> Cmd msg
