module Video exposing (view)

import Html exposing (Html)
import Page exposing (Page(..))

view : String -> Int -> List (Html msg)
view host start =
    [ Html.h2 [] [ Html.text "Video"]
    , Evaluation host start |> Page.internalLink "Conclude appointment" 
    , Html.p [] [ Html.text "The purpose of tis page is to facilitate the actual videocall. The video call is between two people and the UI must make sure it is apparent that the other end is receiving your video and audio and that it is obvious when the other end can hear and see you. It should be possible to resume a call by surfing to this url. It should expose some way to let other parts of the app it's embedded into that the call is still going on. Maybe keep some data in localstorage?"]
    ]

