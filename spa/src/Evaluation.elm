module Evaluation exposing (view)

import Html exposing (Html)
import Page exposing (Page(..))

view : String -> Int -> List (Html msg)
view host start =
    [ Html.h2 [] [ Html.text "Evaluation"]
    , Appointment host start |> Page.internalLink "Back to appointment" 
    , Html.p [] [ Html.text "This is the page you land on after the call is over. For now it will only have some message to inform the user that the call is over."]
    ]