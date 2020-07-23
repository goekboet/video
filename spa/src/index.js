let appelement = document.getElementById("entrypoint");

let appname = appelement.getAttribute("data-appname")

let app = Elm.Main.init({ flags: appname });