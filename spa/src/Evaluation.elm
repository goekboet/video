module Evaluation exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Page exposing (Page(..))

view : String -> Int -> List (Html msg)
view host start =
    [ Html.h2 [] [ Html.text "Evaluation"]
    , Html.p [] [ Html.text "This is the page you land on after the call is over. For now it will only have some message to inform the user that the call is over."]
    , Html.p [] 
      [ Html.text "Go back to the "
      , Html.a [ Appointment host start |> Page.toUrl |> Attr.href ] [ Html.text "appointment."]]
    ]