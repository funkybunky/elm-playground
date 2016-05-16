

type alias Model =
  { dieFace : Int
  }

view : Model -> Html Msg
view model =
  div []
    [ h1 [] [ text (toString model.dieFace) ]
    , button [ onClick Roll ] [ text "Roll" ]
    ]

type Msg
  = Roll
  | NewFace Int

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Roll ->
      (model, Random.generate NewFace (Random.int 1 6))

  case msg of
    NewFace newFace ->
      (Model newFace, Cmd.none)

init : (Model, Cmd Msg)
init =
  (Model 1, Cmd.none)
