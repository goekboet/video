-- The purpose of tis page is to facilitate the actual videocall. 
-- The video call is between two people and the UI must make sure 
-- it is apparent that the other end is receiving your video and 
-- audio and that it is obvious when the other end can hear and 
-- see you. It should be possible to resume a call by surfing to 
-- this url. It should expose some way to let other parts of the 
-- app it's embedded into that the call is still going on. Maybe 
-- keep some data in localstorage?

port module Video exposing (Model, Msg, init, getToken, update, subscriptions, view)

import Html exposing (Html)
import Html.Attributes as Attr
import Page exposing (Page(..))
import Http exposing (Error)
import Url.Builder exposing (absolute)
import FontAwesome as FA
import Html.Events exposing (onClick)

type ConnectionStatus 
    = Closed
    | Pending
    | Errored
    | Open

type CounterPartStatus
    = Waiting
    | Online
    | Offline

type alias Model = 
    { connection : ConnectionStatus
    , counterpart : CounterPartStatus
    }

connected : Model -> Model
connected m = { m | connection = Open }

counterpartJoined : Model -> Model
counterpartJoined m = { m | counterpart = Online }

counterpartLeft : Model -> Model
counterpartLeft m = { m | counterpart = Offline }

close : Model
close = { connection = Closed, counterpart = Offline }

connectionError : Model -> Model
connectionError m = { m | connection = Errored }

reconnection : Model -> Model
reconnection m = { m | connection = Pending }

init : Model
init = { connection = Pending, counterpart = Waiting }

type Msg
    = Noop
    | GotToken (Result Error String)
    | TwilioConnection (Maybe String)
    | Disconnect
    | Reconnect String Int
    | CounterpartJoined String
    | CounterpartLeft String

getToken : (Msg -> msg) -> String -> Int -> Cmd msg
getToken toApp host start =
    Http.get
    { url = absolute [ "api", "appointment", host, String.fromInt start, "token" ] []
    , expect = Http.expectString (toApp << GotToken)
    }

port connect : String -> Cmd msg
port disconnect : () -> Cmd msg

update : (Msg -> msg) -> Msg -> Model -> (Model, Cmd msg)
update toApp msg model =
    case msg of
        Noop -> (model, Cmd.none)
        GotToken (Ok t) -> 
            (model, connect t)
        GotToken (Err _) -> 
            (connectionError model, Cmd.none)
        TwilioConnection (Just _) ->
            (connected model, Cmd.none)
        TwilioConnection Nothing ->
            (connectionError model, Cmd.none)
        Disconnect ->
            (close, disconnect ())
        Reconnect h s ->
            (reconnection model, getToken toApp h s)
        CounterpartJoined _ -> (counterpartJoined model, Cmd.none)
        CounterpartLeft _ -> (counterpartLeft model, Cmd.none)

port connection : (Maybe String -> msg) -> Sub msg
port counterpartJoinedSignal : (String -> msg) -> Sub msg
port counterpartLeftSignal : (String -> msg) -> Sub msg

subscriptions : (Msg -> msg) -> Sub msg
subscriptions toApp = 
    Sub.batch
    [ connection (toApp << TwilioConnection)
    , counterpartJoinedSignal (toApp << CounterpartJoined)
    , counterpartLeftSignal (toApp << CounterpartLeft)
    ]

mediaElement : (Msg -> msg) -> Model -> String -> Int -> Html msg
mediaElement toApp m h s =
    let
        content = 
            case m.connection of
            Closed -> 
                Html.span [] 
                [ Html.h3 [] [ Html.text "Connection closed" ]
                , Html.p [] 
                  [ Html.text "You can always "
                  , Html.button [ Reconnect h s |> toApp |> onClick ] [ Html.text "Reconnect." ]
                  ]
                ]
            Pending -> 
                FA.fas_fa_sync_alt_rolls
            Errored ->
                Html.span [] 
                [ Html.h3 [] [ Html.text "Connection Errored" ]
                , Html.p [] 
                  [ Html.text "Something went wrong with your connection. You can always try to "
                  , Html.button [ Reconnect h s |> toApp |> onClick ] [ Html.text "Reconnect." ]
                  ]
                ]
            Open -> Html.text ""
    in
       Html.div [ Attr.id "Media" ] [ content ] 

disconnectButton : (Msg -> msg) -> Model -> Html msg  
disconnectButton toApp m =
    case m.connection of
    Open -> 
        Html.button 
        [ Attr.class "disconnectButton"
        , onClick (Disconnect |> toApp)] 
        [ Html.text "Disconnect" ]
    _ ->
        Html.button 
        [ Attr.class "disconnectButton"
        , Attr.disabled True ] 
        [ Html.text "Disconnect" ]

counterpartStatus : Model -> Html msg
counterpartStatus m =
    let
        status = 
            case m.counterpart of
            Waiting -> "Counterpart: (waiting to join)"
            Online -> "Counterpart: (online)"
            Offline -> "Counterpart: (offline)"
    in
    Html.span [ Attr.class "remoteParticipant" ] 
      [ Html.label [] [ Html.text status ]
      , Html.button [] [ Html.text "Audio" ]
      , Html.button [] [ Html.text "Video" ]
      ]

view : (Msg -> msg) -> Model -> String -> Int -> List (Html msg)
view toApp m host start =
    [ Html.h2 [] [ Html.text "Video" ]
    , Html.span [ Attr.class "localTracks" ] 
      [ Html.button [] [ Html.text "Audio" ]
      , Html.button [] [ Html.text "Video" ] 
      ]
    , mediaElement toApp m host start 
    , counterpartStatus m
    , disconnectButton toApp m 
    ]

