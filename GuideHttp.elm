import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
--import Json.Decode as Json
import Task
import HttpBuilder exposing (..)
import Json.Decode as DecodeJson
import Json.Encode as EncodeJson
-- import Json exposing (Decode, Encode)
import Time

main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL

type alias Model =
  { topic : String
  , gifUrl: String
  , errorMsg: String
  }

--type alias Bla =
--        { data : String         , headers : Dict.Dict String String         , status : Int         , statusText : String         , url : String         }

init : (Model, Cmd Msg)
init =
  (Model "cats" "waiting.gif" "", Cmd.none)

-- UPDATE

type Msg
  = MorePlease
  | FetchSucceed String -- holds the new gif Url
  | FetchFail Http.Error
  | ChangeTopic String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MorePlease ->
      (model, getRandomGif model.topic)
    FetchSucceed newGifUrl ->
      ({ model | gifUrl = newGifUrl }, Cmd.none)
      -- (Model model.topic newGifUrl, Cmd.none)
    FetchFail error ->
      ( { model | errorMsg = "Sorry: " ++ toString error }, Cmd.none )
      -- (Model model.errorMsg (toString error), Cmd.none)
      -- (model, Cmd.none)
    ChangeTopic newTopic ->
      ( { model | topic = newTopic }, Cmd.none )

-- Where does this fn belong?
getRandomGif : String -> Cmd Msg -- Cmd Msg
getRandomGif topic =
  let
    url =
      "http://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic
  in
    Task.perform FetchFail FetchSucceed (Http.fromJson decodeGifUrl (corsGet url))

--corsGet : String -> Task.Task Http.RawError Http.Response
corsGet url =
  Http.send Http.defaultSettings
    { verb = "GET"
    , headers = []
      {- Setting those headers is not allowed anyway due to browser security restrictions
      [ ("Origin", "127.0.0.1")
      --, ("Access-Control-Allow-Origin", "http://api.giphy.com")
      , ("Access-Control-Request-Method", "GET")
      , ("Access-Control-Request-Headers", "X-Custom-Header")
      ]-}
    , url = url
    , body = Http.empty
    }

getValue (task, err, response) =
  (task, err, response.value)

decodeGifUrl : DecodeJson.Decoder String
decodeGifUrl =
  DecodeJson.at ["data", "image_url"] DecodeJson.string


itemsDecoder : DecodeJson.Decoder (List String)
itemsDecoder =
  DecodeJson.list DecodeJson.string


itemEncoder : String -> EncodeJson.Value
itemEncoder item =
  EncodeJson.object
    [ ("item", EncodeJson.string item) ]


getGif : String -> Task.Task (HttpBuilder.Error String) (HttpBuilder.Response String)
getGif url =
  HttpBuilder.get url
    |> withHeader "Content-Type" "application/json"
    |> withTimeout (10 * Time.second)
    |> withCredentials
    |> send (jsonReader decodeGifUrl) stringReader


-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ h2 [] [text ("Topic: " ++ model.topic) ]
    , button [onClick MorePlease] [text "More Please!"]
    , img [src model.gifUrl] []
    , input [placeholder model.topic, onInput ChangeTopic] [] -- need new Action
    , div [] [text model.errorMsg]
    ]


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
