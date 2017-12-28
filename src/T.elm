import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List
import Task
import String
import Json.Decode as Json
import Time exposing (..)

main : Program ProgramOptions Model Msg
main =
  Html.programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = (\_ -> every second Tick)
    }



-- MODEL

type alias ProgramOptions =
    { elapsed : Float
    }


type alias Position =
  { x : Float
  , y : Float
  }

type alias Dot =
  { val : String
  , hover : Bool
  , p : Position
  , s : Float
  }

type alias Model =
  { dots : List Dot
  , current : Int
  , elapsed : Float
  }

targetSize : Float
targetSize = 25.0

defautDots : List Dot
defautDots = genDS 0.0 0.0 1000.0


genD x y = Dot "0" False (Position x y) targetSize

genDS : Float -> Float -> Float -> List Dot
genDS x y s =
    let nextS = s / 2
    in
        if s <= targetSize
        then [ genD x y ]
        else List.append (List.append (genDS x (y - nextS / 2) nextS) (genDS (x - nextS) (y + nextS / 2) nextS)) (genDS (x + nextS) (y + nextS / 2) nextS)

generateDots : Position -> Int -> List Dot
generateDots p x = []

init : ProgramOptions -> ( Model, Cmd Msg )
init opt =
    ( Model defautDots 0 opt.elapsed, Cmd.none )


-- UPDATE


type Msg
  = MouseEnterDot Dot
  | MouseLeaveDot Dot
  | Tick Time

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MouseEnterDot dot -> ({ model | dots = updateDotEnter model.dots dot }, Cmd.none)
    MouseLeaveDot dot -> ({ model | dots = updateDotLeave model.dots dot }, Cmd.none)
    Tick t -> ({ model | current = (formatT t), dots = (updateDots model.dots (formatT t)) }, Cmd.none)


onMouseEvent : (Dot -> Dot) -> List Dot -> Dot -> List Dot
onMouseEvent fn ds d = case ds of
                           [] -> []
                           (x::xs) -> if x == d then (fn x) :: xs else x :: (onMouseEvent fn xs d)

updateDotEnter : List Dot -> Dot -> List Dot
updateDotEnter = onMouseEvent onEnter

updateDotLeave : List Dot -> Dot -> List Dot
updateDotLeave = onMouseEvent onLeave

onEnter : Dot -> Dot
onEnter d = { d | val = hoverString d.val, hover = True }

onLeave : Dot -> Dot
onLeave d = { d | val = String.slice 1 -1 d.val, hover = False }

hoverString : String -> String
hoverString v = "*" ++ v ++ "*"

updateDots : List Dot -> Int -> List Dot
updateDots dots t = List.map (\dot -> { dot | val = updateDotV dot t}) dots

updateDotV : Dot -> Int -> String
updateDotV dot t = if dot.hover then hoverString (toString t) else (toString t)


formatT : Time -> Int
formatT t = ((truncate (t / 1000)) % 10)

-- VIEW

view : Model -> Html Msg
view model =
    let t = toFloat ((truncate (model.elapsed / 1000)) % 10)
        scale = 1 + (if t > 5 then 10 - t else t) / 10
        styles =
          [ ("position", "absolute")
          , ("transformOrigin", "0 0")
          , ("left", "50%")
          , ("top", "50%")
          , ("width", "10px")
          , ("height", "10px")
          , ("background", "#eee")
          , ("transform", "scaleX(" ++ (toString (scale / 2.1)) ++ ") scaleY(0.7) translateZ(0.1px)")
          ]
  in
  div [style styles]
    (List.map viewDot model.dots)

viewDot : Dot -> Html Msg
viewDot dot =
  let size = (dot.s) * 1.3
      styleStr =
          [ ("position", "absolute")
          , ("font", "normal 15px sans-serif")
          , ("text-align", "center")
          , ("cursor", "pointer")
          , ("width", (toString size) ++ "px")
          , ("height", (toString size) ++ "px")
          , ("left", (toString dot.p.x) ++ "px")
          , ("top", (toString dot.p.y) ++ "px")
          , ("border-radius", (toString (size / 2)) ++ "px")
          , ("line-height", (toString size) ++ "px")
          , ("background", if dot.hover then "#ff0" else "#61dafb")
          ]
  in
  div
    [ style styleStr, onMouseEnter (MouseEnterDot dot), onMouseLeave (MouseLeaveDot dot) ]
    [ text dot.val ]
