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
        let token = mintToken creds.Value "someName" h t
        
        Successful.OK token next ctx

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

[<EntryPoint>]
let main _ =
    let contentRoot = Directory.GetCurrentDirectory()
    let webRoot     = Path.Combine(contentRoot, "WebRoot")
    Host.CreateDefaultBuilder()
        .ConfigureWebHostDefaults(
            fun webHostBuilder ->
                webHostBuilder
                    .UseContentRoot(contentRoot)
                    .UseWebRoot(webRoot)
                    .Configure(Action<IApplicationBuilder> configureApp)
                    .ConfigureServices(configureServices)
                    .ConfigureLogging(configureLogging)
                    |> ignore)
        .Build()
        .Run()
    0