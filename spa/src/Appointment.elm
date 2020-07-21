module Appointment exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Page exposing (Page(..))

view : String -> Int -> List (Html msg)
view host start =
    [ Html.h2 [] [ Html.text "Appointment" ]
    , Html.p [] [ Html.text "The purpose of this page is to display details about the appointment. It will make sure you know when it begins and who's on the other end. It will keep a timer of some sort. This timer will let the user know how long it is until the appoitment starts and then let him or her go to the video-call when it's about to start."]
    , Html.p [] 
      [ Html.text "Proceed to "
      , Html.a [ Video host start |> Page.toUrl |> Attr.href ] [ Html.text "the call."]
      ]
    ]