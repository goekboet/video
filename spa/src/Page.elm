module Page exposing 
    ( Page(..)
    , fromUrl
    , toUrl)

import Url exposing (Url)
import Url.Parser as UrlP exposing (Parser, (</>))
import Url.Builder as UrlB

type Page
    = Appointment String Int
    | Video String Int
    | Evaluation String Int


fromUrl : Url -> Maybe Page
fromUrl url = UrlP.parse route url

route : Parser (Page -> a) a
route =
    UrlP.oneOf
        [  UrlP.s "appointment" </> UrlP.string </> UrlP.int 
           |> UrlP.map Appointment
        ,  UrlP.s "appointment" </> UrlP.string </> UrlP.int </> UrlP.s "video" 
           |> UrlP.map Video
        ,  UrlP.s "appointment" </> UrlP.string </> UrlP.int </> UrlP.s "evaluation" 
           |> UrlP.map Evaluation
        ]

toUrl : Page -> String
toUrl r = 
    case r of
        Appointment h t -> UrlB.absolute [ "appointment", h, String.fromInt t] [] 
        Video h t -> UrlB.absolute [ "appointment", h, String.fromInt t, "video"] []
        Evaluation h t -> UrlB.absolute [ "appointment", h, String.fromInt t, "evaluation" ] []
            