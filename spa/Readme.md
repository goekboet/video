# Simple elm/js/css build

This repo is my project template for building elm apps.

## Description

The `build.sh`-script does three things to build the app in the `src/`-directory.
1. Run `elm make`to output an elm app to `app.js`.
2. Bundle js-dependencies using `index.js` as entrypoint. `index.js` initializes the elm-app and can be written in es6-style and `import` node-modules. Outputs `index.js`.
3. Concatenates all .css-files into a single `style.css`-file.
4. Puts all outputs in a `dist/`-directory.

The project can be expanded by adding css and js dependencies. If the app needs to be served by a proper backend it needs only ever to include the following links inside the `<head></head>`.
```
<link rel="stylesheet" href="style.css">
<script src="app.js"></script>
<script src="index.js" defer></script>
```

## Getting Started

To make a serveable app at `dist/` run `./build -debug`. This app is not minified and will have the elm debug-overlay. Drop the `-debug`-flag to build an optimized app without the overlay. i.e. `./build.sh`. Run the app by `npm start`.

### Dependencies

This repo depends on [elm](https://guide.elm-lang.org/install/elm.html), [node/npm](https://nodejs.org/en/) (LTS is fine) and the following npm-tools. 
```
npm i -g babelify
npm i -g browserify
npm i -g uglify-js
npm i -g serve
```
These tools needs to be runnable from the command-line. Then run `npm i` to install dependencies from `package.json`.

## License

This project is licensed under the MIT License License - see the LICENSE file for details
