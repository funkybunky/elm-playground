import Html exposing (Html)
import Html.Events exposing (onClick)
import Html.App as App
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Time exposing (Time, second)



main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL

type alias Model =
  { time: Time
  , isPaused: Bool
  }


init : (Model, Cmd Msg)
init =
  (Model 0 False, Cmd.none)


-- UPDATE

type Msg
  = Tick Time
  | PauseClock


update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    Tick newTime ->
      ({ model | time = newTime }, Cmd.none)
    PauseClock ->
      ({ model | isPaused = not model.isPaused }, Cmd.none)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  case model.isPaused of
    True ->
      Sub.none
    False ->
      Time.every second Tick


-- VIEW

renderClock : Model -> Html Msg
renderClock model =
  let
    angle =
      turns (Time.inMinutes model.time)

    handX =
      toString (50 + 40 * cos angle)

    handY =
      toString (50 + 40 * sin angle)
  in
    svg [ viewBox "0 0 100 100", width "300px" ]
      [ circle [ cx "50", cy "50", r "45", fill "#0B79CE" ] []
      , line [ x1 "50", y1 "50", x2 handX, y2 handY, stroke "#023963" ] []
      ]

view : Model -> Html Msg
view model =
  Html.div []
    [ renderClock model
    , Html.button [Html.Events.onClick PauseClock] [ text (if model.isPaused then "Move!" else "Halt!")]
    ]
