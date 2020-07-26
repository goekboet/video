module Backend.Twilio

open Twilio.Jwt.AccessToken
open System.Collections.Generic

type TwilioCreds() =
    member val ApiKeySid = "" with get, set
    member val ApiKeySecret = "" with get, set
    member val AccountSid = "" with get, set

let mintToken 
    (creds : TwilioCreds)
    (name : string) 
    (host : string)
    (start : int) =
    
    let roomName = sprintf "%s/%i" host start
    let grant = VideoGrant( Room = roomName )
    let grants = new HashSet<IGrant>();
    grants.Add(grant) |> ignore

    let token = Token ( creds.AccountSid
                      , creds.ApiKeySid
                      , creds.ApiKeySecret
                      , name
                      , System.Nullable()
                      , System.Nullable()
                      , grants)
    token.ToJwt()