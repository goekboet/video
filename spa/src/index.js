import { connect } from 'twilio-video'

let appelement = document.getElementById("entrypoint");

let appname = appelement.getAttribute("data-appname")

let app = Elm.Main.init({ flags: appname });

let disconnect = room => () => {
    room.disconnect()
}

app.ports.connect.subscribe(t => {
    connect(t).then(
        room => {
            app.ports.connection.send(room.name)
            app.ports.disconnect.subscribe(disconnect(room))
        },
        reason => {
            console.log(reason)
            app.ports.connection.send(null)
        })
    
})