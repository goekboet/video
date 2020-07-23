module Backend.SpaRoute

open Giraffe.GiraffeViewEngine

let spa 
    (username : string option) =

    let usernameData (n : string option) =
        Option.map (fun u -> attr "data-username" u) username 
                   |> Option.defaultValue (flag "")

    html [] [
        head [] [
            title []  [ str "Publish" ];
            meta [ _charset "UTF-8" ];
            meta [ _name "viewport"; _content "width=device-width, initial-scale=1.0"];
            link [ _rel "stylesheet" ; _href "/appointment/app.css" ];
            link [ _rel "stylesheet" ; _href "/common.css" ];
            link [ _rel "stylesheet" ; _href "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.13.0/css/all.min.css" ];
            script [ _src "/appointment/app.js" ] []; 
            script 
                [ _id "entrypoint"
                ; _src "/appointment/index.js"
                ; _defer 
                ; usernameData username
                ; attr "data-appname" "Appointment" 
                ] []
        ]
        body [] []
    ]


