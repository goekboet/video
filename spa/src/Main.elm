module Main exposing (main)

import Html exposing (Html, h1, p, div, text, a)
import Html.Events exposing (onClick)
import Html.Attributes as Attr exposing (class, href)
import Page exposing (Page(..))
import Url exposing (Url)
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav exposing (Key)
import Appointment
import Video
import Evaluation


-- MAIN

type alias Flags = String

main : Program Flags Model Msg
main =
  Browser.application 
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlChange = UrlChanged
    , onUrlRequest = LinkClicked
    }



-- MODEL

type alias Model = 
  { appName : String
  , key : Key
  , page : Maybe Page
  }

init : Flags -> Url -> Key -> (Model, Cmd Msg)
init f url key =
  let
      p = Page.fromUrl url
  in
    (
    { appName = f
    , key = key
    , page = p
    }
    , Cmd.none)
  


-- UPDATE

type Msg 
  = LinkClicked UrlRequest
  | UrlChanged Url

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
  case msg of
    LinkClicked urlRequest ->
      case urlRequest of
        Browser.Internal url ->
          ( model, Nav.pushUrl model.key (Url.toString url) ) 

        Browser.External href ->
          ( model, Nav.load href )

    UrlChanged url ->
      let
        destination = Page.fromUrl url
      in
        ( { model | page = destination }
        , case destination of
          Just (Appointment h s) -> Cmd.none
          Just (Video h s) -> Cmd.none
          Just (Evaluation h s) -> Cmd.none
          _ -> url |> Url.toString |> Nav.load
        )


-- VIEW
homelink : String -> Html msg
homelink appName =
    div [ class "content"
        , class "heavy" 
        ] 
        [ h1 [] 
          [ a [ Attr.href "/" ] [ text appName ] ]
        ]

routeToPage : Maybe Page -> List (Html msg)
routeToPage p =
  case p of
  Just (Appointment h s) -> Appointment.view h s
  Just (Video h s) -> Video.view h s 
  Just (Evaluation h s) -> Evaluation.view h s
  Nothing -> []

view : Model -> Browser.Document Msg
view m =
  { title = "Publish"
    , body =
        [ div 
        [ class "root-view" ] 
        [ homelink m.appName
        , routeToPage m.page |> 
          div 
          [ class "content"
          , class "light"
          , class "app-view" 
          ] 
           
        ] 
      ]
    }
  

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none