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
            link [ _rel "stylesheet" ; _href "/style.css" ];
            link [ _rel "stylesheet" ; _href "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.13.0/css/all.min.css" ];
            script [ _src "/app.js" ] []; 
            script 
                [ _id "entrypoint"
                ; _src "/index.js"
                ; _defer 
                ; usernameData username 
                ] []
        ]
        body [] []
    ]


