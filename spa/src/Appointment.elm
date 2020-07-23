module Appointment exposing 
    ( Model
    , init
    , Msg
    , getTimezone
    , getAppointment
    , update
    , view
    )

import Html exposing (Html)
import Page exposing (Page(..))
import Http exposing (Error)
import Url.Builder exposing (absolute)
import Json.Decode as Json exposing (Decoder)
import Html.Events exposing (onClick)
import Html.Attributes as Attr
import FontAwesome as FA
import Task
import Time exposing (Zone)

type alias Appointment =
    { start : Int
    , end : Int
    , name : String
    , host : String
    , counterPart : String
    }

decodeAppointment : Decoder Appointment
decodeAppointment =
    Json.map5 Appointment
    (Json.field "start" Json.int)
    (Json.field "end" Json.int)
    (Json.field "name" Json.string)
    (Json.field "host" Json.string)
    (Json.field "counterPart" Json.string)

type AppointmentRequest =
    Pending
    | Received Appointment
    | Errored

type alias Model =
    { tz : Maybe Zone
    , appointment : AppointmentRequest
    }

getTime : Model -> (Appointment -> Int) -> String
getTime m time =
    case (m.tz, m.appointment) of
    (Just z, Received appt) -> 
        let
            posix = Time.millisToPosix (time appt * 1000)
        in
            String.concat 
            [ Time.toHour z posix |> String.fromInt |> String.padLeft 2 '0'
            , ":"
            , Time.toMinute z posix |> String.fromInt |> String.padLeft 2 '0'
            ]
        
    _ -> ""

type Msg 
    = Noop
    | GotZone Zone
    | Refetch String Int
    | AppointmentReceived (Result Error Appointment)

init : Model
init = 
   { tz = Nothing
   , appointment = Pending
   }

getTimezone : (Msg -> msg) -> Cmd msg
getTimezone toApp = Task.perform (toApp << GotZone) Time.here

getAppointment : (Msg -> msg) -> String -> Int -> Cmd msg
getAppointment toApp host start =
    Http.get
    { url = absolute [ "api", "appointment", host, String.fromInt start] []
    , expect = Http.expectJson (toApp << AppointmentReceived) decodeAppointment
    }

update : (Msg -> msg) -> Msg -> Model -> (Model, Cmd msg)
update toApp msg model =
    case msg of
        Noop ->
            (model, Cmd.none)

        GotZone z ->
            ( { model | tz = Just z }, Cmd.none )

        Refetch h s ->
            ({ model | appointment = Pending }, getAppointment toApp h s)

        AppointmentReceived (Ok appt) ->
            ({ model | appointment = Received appt }, Cmd.none)

        AppointmentReceived (Err _) ->
            ({ model | appointment = Errored }, Cmd.none)


view : (Msg -> msg) -> String -> Int -> Model -> List (Html msg)
view toApp host start m =
    case m.appointment of
    Pending -> [ Html.span [ Attr.class "appointmentPending" ] [ FA.fas_fa_sync_alt_rolls]]
    Received appt -> 
        [ Html.h2 [] [ Html.text appt.name ] 
        , Html.p [] 
          [ Html.text "You're meeting "
          , Html.b [] [ Html.text appt.counterPart ]
          , Html.text " from "
          , Html.b [] [ Html.text appt.host] 
          , Html.text ". Your appointment starts at "
          , Html.b [] [ Html.text (getTime m .start)]
          , Html.text " and is scheduled to end "
          , Html.b [] [ Html.text (getTime m .end)]
          , Html.text ". 5 minutes before the appointment starts you can proceed to call." ]
          , Video host start |> Page.internalLink "Proceed to call"
          ]
    Errored -> 
        [ Html.h2 [] [ Html.text "Something went wrong"] 
        , Html.span [ Attr.class "appointmentFail" ]
          [ FA.fas_fa_exclamation_triangle
          , Html.p [] 
            [ Html.text "We could not fetch your appointment at this time. You can always "
            , Html.button [ Refetch host start |> toApp |> onClick ] [ Html.text "try again" ]
            ]
          ]
        ]

    
    

-- view : String -> Int -> List (Html msg)
-- view host start =
--     [ Html.h2 [] [ Html.text "Appointment" ]
--     , Video host start |> Page.internalLink "Proceed to call" 
--     , Html.p [] [ Html.text "The purpose of this page is to display details about the appointment. It will make sure you know when it begins and who's on the other end. It will keep a timer of some sort. This timer will let the user know how long it is until the appoitment starts and then let him or her go to the video-call when it's about to start."]
--     ]