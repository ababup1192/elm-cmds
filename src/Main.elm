module Main exposing (main)

import Browser
import Html exposing (Html, main_, p, text)
import Html.Attributes exposing (class)
import Http
import Json.Decode as JD
import Random
import Task



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { asyncString : String
    , randomNumber : Int
    , joke : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { asyncString = ""
      , randomNumber = -1
      , joke = ""
      }
    , Cmd.batch
        [ getAsyncString
        , getRandomNumber
        , getJoke
        ]
    )



-- UPDATE


getAsyncString : Cmd Msg
getAsyncString =
    Task.perform GotAsyncString <|
        Task.succeed "AsyncString"


getRandomNumber : Cmd Msg
getRandomNumber =
    Random.generate GotRandomNumber <| Random.int 0 100


getJoke : Cmd Msg
getJoke =
    Http.get
        { url = "https://official-joke-api.appspot.com/random_joke"
        , expect = Http.expectJson GotJoke <| JD.field "setup" JD.string
        }


type Msg
    = GotAsyncString String
    | GotRandomNumber Int
    | GotJoke (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotAsyncString str ->
            ( { model | asyncString = str }, Cmd.none )

        GotRandomNumber num ->
            ( { model | randomNumber = num }, Cmd.none )

        GotJoke res ->
            case res of
                Ok joke ->
                    ( { model | joke = joke }, Cmd.none )

                Err _ ->
                    ( { model | joke = "Error" }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    main_ [ class "ly_cont" ]
        [ p [] [ text <| "async: " ++ model.asyncString ]
        , p [] [ text <| "random: " ++ String.fromInt model.randomNumber ]
        , p [] [ text <| "joke: " ++ model.joke ]
        ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
