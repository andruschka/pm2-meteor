
[![deffy](http://i.imgur.com/k1hlQxA.png)](#)

# deffy [![PayPal](https://img.shields.io/badge/%24-paypal-f39c12.svg)][paypal-donations] [![Version](https://img.shields.io/npm/v/deffy.svg)](https://www.npmjs.com/package/deffy) [![Downloads](https://img.shields.io/npm/dt/deffy.svg)](https://www.npmjs.com/package/deffy) [![Get help on Codementor](https://cdn.codementor.io/badges/get_help_github.svg)](https://www.codementor.io/johnnyb?utm_source=github&utm_medium=button&utm_term=johnnyb&utm_campaign=github)

> Small and fast library to set default values.

## :cloud: Installation

```sh
$ npm i --save deffy
```


## :clipboard: Example



```js
// Dependencies
var Deffy = require("deffy");

console.log(Deffy(undefined, "Hello World"));
// => "Hello World"

console.log(Deffy("Hello World", 42));
// => 42

console.log(Deffy("Hello", "World"));
// => "World"

console.log(Deffy("", "World", true));
// => "World"

console.log(Deffy("", "World"));
// => ""

console.log(Deffy("foo", function (input) {
    return input === "foo" ? "bar" : "foo";
}));
// => "bar"
```

## :memo: Documentation


### `Deffy(input, def, options)`
Computes a final value by providing the input and default values.

#### Params
- **Anything** `input`: The input value.
- **Anything|Function** `def`: The default value or a function getting the input value as first argument.
- **Object|Boolean** `options`: The `empty` value or an object containing the following fields:

 - `empty` (Boolean): Handles the input value as empty field (`input || default`). Default is `false`.

#### Return
- **Anything** The computed value.



## :yum: How to contribute
Have an idea? Found a bug? See [how to contribute][contributing].

## :dizzy: Where is this library used?
If you are using this library in one of your projects, add it in this list. :sparkles:


 - [`ascii-heart`](https://github.com/nuvipannu/ascii-heart#readme) (by Nuvi Pannu)—Create ASCII hearts using Node.js.
 - [`asciify-pixel`](https://github.com/IonicaBizau/asciify-pixel#readme)—Asciifies a pixel object.
 - [`blah`](https://github.com/IonicaBizau/blah)—A command line tool to optimize the repetitive actions.
 - [`bug-killer`](https://github.com/IonicaBizau/node-bug-killer)—Simple way to log messages in stdout or other stream.
 - [`cli-box`](https://github.com/IonicaBizau/node-cli-box)—A library to generate ASCII boxes via NodeJS
 - [`cli-gh-cal`](https://github.com/IonicaBizau/cli-gh-cal)—GitHub like calendar graphs in command line.
 - [`emoji-logger`](https://github.com/IonicaBizau/emoji-logger#readme)—Logging library based on flat colors and Emoji.
 - [`engine-builder`](https://github.com/IonicaBizau/engine-parser) (by jillix)—Engine composition parser.
 - [`engine-flow-types`](https://github.com/jillix/engine-flow-types#readme) (by jillix)—Low level library providing Engine flow types.
 - [`engine-parser`](https://github.com/IonicaBizau/engine-parser) (by jillix)—Engine composition parser.
 - [`engine-tools`](https://github.com/jillix/engine-tools) (by jillix)—Engine Tools library and CLI app.
 - [`enny`](https://github.com/IonicaBizau/enny) (by jillix)—Generate Engine compositions from human-readable inputs.
 - [`flow-api`](https://github.com/jillix/flow-api) (by jillix)—The flow api library and CLI app.
 - [`gh-notifier`](https://bitbucket.org/IonicaBizau/gh-notifier#readme)—Receive desktop notifications from your GitHub dashboard.
 - [`ghosty`](https://github.com/IonicaBizau/ghosty#readme)—A wrapper around PhantomJS, downloading the Phantom binary.
 - [`git-package-json`](https://github.com/IonicaBizau/git-package-json#readme)—Get the package.json contents from git repositories.
 - [`git-stats`](https://github.com/IonicaBizau/git-stats)—Local git statistics including GitHub-like contributions calendars.
 - [`gpm`](https://github.com/IonicaBizau/gpm)—npm + git = gpm - Install NPM packages and dependencies from git repositories.
 - [`love-you`](https://github.com/IonicaBizau/love-you#readme)—"I love you" in different languages.
 - [`one-by-one`](https://github.com/IonicaBizau/one-by-one)—Run async tasks one by one.
 - [`pixel-class`](https://github.com/IonicaBizau/pixel-class#readme)—A tiny class for pixel manipulation.
 - [`same-time`](https://github.com/IonicaBizau/same-time.js)—Call functions in parallel and store the results.
 - [`set-or-get`](https://github.com/IonicaBizau/set-or-get.js)—Sets or gets an object field value.
 - [`ssh-remote`](https://github.com/IonicaBizau/ssh-remote)—Automagically switch on the SSH remote url in a Git repository.
 - [`svg.connectable.js`](https://github.com/jillix/svg.connectable.js) (by jillix)—A JavaScript library for connecting SVG things.
 - [`tilda`](https://github.com/IonicaBizau/tilda)—Tiny module for building command line tools.
 - [`ul`](https://github.com/IonicaBizau/node-ul)—A minimalist utility library.
 - [`web-term`](https://github.com/IonicaBizau/web-term)—A full screen terminal in your browser.

## :scroll: License

[MIT][license] © [Ionică Bizău][website]

[paypal-donations]: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=RVXDDLKKLQRJW
[donate-now]: http://i.imgur.com/6cMbHOC.png

[license]: http://showalicense.com/?fullname=Ionic%C4%83%20Biz%C4%83u%20%3Cbizauionica%40gmail.com%3E%20(http%3A%2F%2Fionicabizau.net)&year=2015#license-mit
[website]: http://ionicabizau.net
[contributing]: /CONTRIBUTING.md
[docs]: /DOCUMENTATION.md
