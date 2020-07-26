module Backend.App

open System
open System.IO
open Microsoft.AspNetCore.Builder
open Microsoft.AspNetCore.Hosting
open Microsoft.AspNetCore.Http
open Microsoft.Extensions.Configuration
open Microsoft.Extensions.DependencyInjection
open Microsoft.Extensions.Logging
open Microsoft.Extensions.Hosting
open Giraffe
open Backend.SpaRoute
open Backend.Twilio
open Microsoft.Extensions.Options
open System.Collections.Generic

// ---------------------------------
// Models
// ---------------------------------

type Message =
    {
        Text : string
    }

// ---------------------------------
// Views
// ---------------------------------

module Views =
    open GiraffeViewEngine



type Appointment =
    { Start : int
      End : int;
      Name : string
      Host : string
      CounterPart : string
      }

let appointmentH (h : string, t : int) : HttpHandler
    =
    json { Start = 1594796400; End = 1594958400; Name = "Counsel"; Host = "A hostier host"; CounterPart = "John Carpenter"}

let getToken (h: string, t : int) : HttpHandler
    =
    fun (next : HttpFunc) (ctx : HttpContext) ->
        let creds = ctx.GetService<IOptions<TwilioCreds>>()
        let conf = ctx.GetService<IConfiguration>()
        let name = conf.GetValue("Testdata:User")
        let token = mintToken creds.Value name h t
        
        setBodyFromString token next ctx

// ---------------------------------
// Web app
// ---------------------------------

let webApp =
    choose [
        route "/" >=> text "App reloaded"
        routef "/api/appointment/%s/%i" appointmentH
        routef "/api/appointment/%s/%i/token" getToken
        htmlView (spa None)
        setStatusCode 404 >=> text "Not Found" ]

// ---------------------------------
// Error handler
// ---------------------------------

let errorHandler (ex : Exception) (logger : ILogger) =
    logger.LogError(ex, "An unhandled exception has occurred while executing the request.")
    clearResponse >=> setStatusCode 500 >=> text ex.Message

// ---------------------------------
// Config and Main
// ---------------------------------

let configureApp (app : IApplicationBuilder) =
    app.UseGiraffeErrorHandler(errorHandler)
        .UseStaticFiles()
        .UseGiraffe(webApp)

let configureServices (services : IServiceCollection) =
    let serviceProvider = services.BuildServiceProvider()
    let settings = serviceProvider.GetService<IConfiguration>()

    services.AddGiraffe() |> ignore
    services.Configure<TwilioCreds>(settings.GetSection("Twilio")) |> ignore

let configureLogging (builder : ILoggingBuilder) =
    builder.AddFilter(fun l -> l.Equals LogLevel.Information)
           .AddConsole()
           .AddDebug() |> ignore


// For testing we need to be able to have browse the app from two different browsers
// where one is using a different name than the other. Normally this name would come from 
// the authentication but here we will hardcode it via a command-line argument.
// i.e.
// dotnet run Port=5091 User=Alice
// dotnet run Port=5092 User=Bob
[<EntryPoint>]
let main args =
    let contentRoot = Directory.GetCurrentDirectory()
    let webRoot     = Path.Combine(contentRoot, "WebRoot")
    
    let port = 
        Seq.tryFind (fun (x: string) -> x.StartsWith("Port=")) args
        |> Option.map (fun x -> x.Substring(5))
        |> Option.defaultWith(fun _ -> "5090")

    let testdata =
        Seq.tryFind (fun (x : string) -> x.StartsWith("User=")) args
        |> Option.map (fun x ->
            let d = new Dictionary<string, string>() 
            let u = x.Substring(5)
            d.Add("Testdata:User", u) |> ignore
            d)
        |> Option.defaultWith(fun _ -> new Dictionary<string, string>())

    Host.CreateDefaultBuilder()
        .ConfigureWebHostDefaults(
            fun webHostBuilder ->
                webHostBuilder
                    .UseUrls(sprintf "http://localhost:%s" port)
                    .ConfigureAppConfiguration(fun cfg ->
                        cfg.AddInMemoryCollection(testdata) |> ignore
                        )
                    .UseContentRoot(contentRoot)
                    .UseWebRoot(webRoot)
                    .Configure(Action<IApplicationBuilder> configureApp)
                    .ConfigureServices(configureServices)
                    .ConfigureLogging(configureLogging)
                    |> ignore)
        .Build()
        .Run()
    0