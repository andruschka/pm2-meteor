
# ul

 [![Patreon](https://img.shields.io/badge/Support%20me%20on-Patreon-%23e6461a.svg)][patreon] [![PayPal](https://img.shields.io/badge/%24-paypal-f39c12.svg)][paypal-donations] [![AMA](https://img.shields.io/badge/ask%20me-anything-1abc9c.svg)](https://github.com/IonicaBizau/ama) [![Travis](https://img.shields.io/travis/IonicaBizau/node-ul.svg)](https://travis-ci.org/IonicaBizau/node-ul/) [![Version](https://img.shields.io/npm/v/ul.svg)](https://www.npmjs.com/package/ul) [![Downloads](https://img.shields.io/npm/dt/ul.svg)](https://www.npmjs.com/package/ul) [![Get help on Codementor](https://cdn.codementor.io/badges/get_help_github.svg)](https://www.codementor.io/johnnyb?utm_source=github&utm_medium=button&utm_term=johnnyb&utm_campaign=github)

> A minimalist utility library.

## :cloud: Installation

```sh
$ npm i --save ul
```


## :clipboard: Example



```js
// Dependencies
var Ul = require("ul");

// Input data
var obj = {
        n: null
      , v: 1
    }
  , def = {
        n: 1
      , v: 10
      , a: 20
    }
  , tmp = null
  ;

debugger

// Merge the two objects and store the result in tmp
console.log(tmp = Ul.deepMerge(obj, def));
// => { n: null, v: 1, a: 20 }

// Clone the tmp object -- the clone will have a
// different reference
console.log(tmp === Ul.clone(tmp));
// => false

// Show the absolute path to the home directory
console.log(Ul.home()); // or `console.log(Ul.HOME_DIR);`
// => /home/ionicabizau

// One level merge
console.log(Ul.merge({
    foo: {
        bar: 42
    }
}, {
    foo: {
        bar: 1
      , baz: 7
    }
}));
// => { { bar: 42 } }
```

## :memo: Documentation


### `merge(dst, src)`
One level merge. Faster than `deepMerge`.

#### Params
- **** `dst`: {Object} The destination object.
- **** `src`: {Object} The source object (usually defaults).

#### Return
- **Object** The result object.

### `deepMerge()`
Recursively merge the objects from arguments, returning a new object.

Usage: `Ul.deepMerge(obj1, obj2, obj3, obj4, ..., objN)`

#### Return
- **Object** The merged objects.

### `clone(item)`
Deep clone of the provided item.

#### Params
- **Anything** `item`: The item that should be cloned

#### Return
- **Anything** The cloned object

### `home()`
Get the home directory path on any platform. The value can be
accessed using `Ul.HOME_DIR` too.

#### Return
- **String** The home directory path.



## :yum: How to contribute
Have an idea? Found a bug? See [how to contribute][contributing].


## :moneybag: Donations

Another way to support the development of my open-source modules is
to [set up a recurring donation, via Patreon][patreon]. :rocket:

[PayPal donations][paypal-donations] are appreciated too! Each dollar helps.

Thanks! :heart:

## :dizzy: Where is this library used?
If you are using this library in one of your projects, add it in this list. :sparkles:


 - [`3abn`](https://github.com/IonicaBizau/3abn#readme)—A 3ABN radio client in the terminal.
 - [`abs`](https://github.com/IonicaBizau/abs)—A library to convert a path into an absolute path.
 - [`ansy`](https://github.com/IonicaBizau/ansy#readme)—Cross platform ANSI colors made easy.
 - [`ascii-heart`](https://github.com/nuvipannu/ascii-heart#readme) (by Nuvi Pannu)—Create ASCII hearts using Node.js.
 - [`asciify-pixel`](https://github.com/IonicaBizau/asciify-pixel#readme)—Asciifies a pixel object.
 - [`asciify-pixel-matrix`](https://github.com/IonicaBizau/asciify-pixel-matrix#readme)—Asciifies a matrix of pixels.
 - [`bible`](https://github.com/BibleJS/BibleApp)—Read the Holy Bible via the command line.
 - [`bible.js`](https://github.com/BibleJS/bible.js)—The Bible as a NPM module.
 - [`birthday`](https://github.com/IonicaBizau/birthday)—Know when a friend's birthday is coming.
 - [`blah`](https://github.com/IonicaBizau/blah)—A command line tool to optimize the repetitive actions.
 - [`bloggify`](https://github.com/Bloggify/bloggify-tools)—A set of tools for Bloggify administration.
 - [`bloggify-config`](https://github.com/Bloggify/bloggify-config#readme) (by Bloggify)—Helper module to create Bloggify configuration.
 - [`bloggify-markdown-adapter`](https://github.com/IonicaBizau/bloggify-markdown-adapter#readme)—Markdown adapter for Bloggify.
 - [`bloggify-social`](https://github.com/Bloggify/social)—A Bloggify plugin for sharing articles on social networks.
 - [`bloggify-viewer`](https://github.com/IonicaBizau/bloggify-viewer#readme)—Connects the CRUD operations with the renderer.
 - [`bnotify`](https://github.com/IonicaBizau/bnotify)—A notification system written in NodeJS using the BAT platform.
 - [`cdnjs-importer`](https://github.com/cdnjs/cdnjs-importer)—Easy way to import a library into CDNJS.
 - [`class-methods`](https://github.com/IonicaBizau/class-methods#readme)—Get the methods of a JavaScript class.
 - [`cli-box`](https://github.com/IonicaBizau/node-cli-box)—A library to generate ASCII boxes via NodeJS
 - [`cli-circle`](https://github.com/IonicaBizau/node-cli-circle)—Generate ASCII circles with NodeJS.
 - [`cli-gh-cal`](https://github.com/IonicaBizau/cli-gh-cal)—GitHub like calendar graphs in command line.
 - [`cli-graph`](https://github.com/IonicaBizau/node-cli-graph)—Easily draw function graphs in text mode.
 - [`cli-pie`](https://github.com/IonicaBizau/node-cli-pie)—Generate pie charts in terminal and text mode.
 - [`cli-snow`](https://github.com/IonicaBizau/cli-snow)—Snow, snow, snow! Let it snow, in terminal!
 - [`cobol`](https://github.com/IonicaBizau/node-cobol)—COBOL bridge for NodeJS which allows you to run COBOL code from NodeJS.
 - [`compute-size`](https://github.com/IonicaBizau/compute-size#readme)—Helper tool for resizing the things.
 - [`diable`](https://github.com/IonicaBizau/diable)—Daemonize the things out.
 - [`donate.js`](https://github.com/IonicaBizau/donate.js)—A JavaScript library for creating a friendly way to send money donations.
 - [`electronify`](https://github.com/IonicaBizau/electronify#readme)—The simplest way to build Electron apps.
 - [`emoji-logger`](https://github.com/IonicaBizau/emoji-logger#readme)—Logging library based on flat colors and Emoji.
 - [`engine-builder`](https://github.com/IonicaBizau/engine-parser) (by jillix)—Engine composition parser.
 - [`engine-flow-types`](https://github.com/jillix/engine-flow-types#readme) (by jillix)—Low level library providing Engine flow types.
 - [`engine-parser`](https://github.com/IonicaBizau/engine-parser) (by jillix)—Engine composition parser.
 - [`engine-tools`](https://github.com/jillix/engine-tools) (by jillix)—Engine Tools library and CLI app.
 - [`enny`](https://github.com/IonicaBizau/enny) (by jillix)—Generate Engine compositions from human-readable inputs.
 - [`flow-api`](https://github.com/jillix/flow-api) (by jillix)—The flow api library and CLI app.
 - [`fortran`](https://github.com/IonicaBizau/node-fortran)—Fortran bridge for Node.js which allows you to run Fortran code from Node.js.
 - [`fwatcher`](https://github.com/IonicaBizau/node-fwatcher)—Watch files for changes.
 - [`gh-contributions`](https://github.com/IonicaBizau/github-contributions)—A tool that generates a repository which being pushed into your GitHub account creates a nice contributions calendar.
 - [`gh-fork-source`](https://github.com/IonicaBizau/gh-fork-source#readme)—Get the source repository of a GitHub fork.
 - [`gh.js`](https://github.com/IonicaBizau/gh.js)—Tiny GitHub API wrapper for server and client.
 - [`ghcal`](https://github.com/IonicaBizau/ghcal)—See the GitHub contributions calendar of a user in the command line.
 - [`ghosty`](https://github.com/IonicaBizau/ghosty#readme)—A wrapper around PhantomJS, downloading the Phantom binary.
 - [`git-cloner`](https://github.com/IonicaBizau/git-cloner#readme)—Clone multiple git repositories.
 - [`git-stats`](https://github.com/IonicaBizau/git-stats)—Local git statistics including GitHub-like contributions calendars.
 - [`git-stats-importer`](https://github.com/IonicaBizau/git-stats-importer)—Imports your commits from a repository into git-stats history.
 - [`github-colors`](https://github.com/IonicaBizau/github-colors)—GitHub colors and file extensions mapping
 - [`github-stats`](https://github.com/IonicaBizau/github-stats)—Visualize stats about GitHub users and projects in your terminal.
 - [`gpm`](https://github.com/IonicaBizau/gpm)—npm + git = gpm - Install NPM packages and dependencies from git repositories.
 - [`gry`](https://github.com/IonicaBizau/node-gry)—A minimalist NodeJS wrapper for the `git` commands. `gry` stands for the Git RepositorY.
 - [`idea`](https://github.com/IonicaBizau/idea)—A lightweight CLI tool and module for keeping ideas in a safe place quick and easy.
 - [`image-to-ascii`](https://github.com/IonicaBizau/image-to-ascii)—A Node.JS module that converts images to ASCII art.
 - [`jipics`](https://github.com/jillix/node-jipics) (by jillix)—Node.JS wrapper for jipics image hosting website.
 - [`jsonrequest`](https://github.com/IonicaBizau/jsonrequest)—A tiny library for requesting and getting JSON resources.
 - [`le-table`](https://github.com/IonicaBizau/le-table)—Another NodeJS module for creating ASCII tables.
 - [`lien`](https://github.com/LienJS/Lien)—Another lightweight NodeJS framework. Lien is the link between request and response objects.
 - [`made-in`](https://github.com/IonicaBizau/made-in#readme)—Get GitHub projects created by users from a specific location.
 - [`markdown-templator`](https://github.com/grit96/markdown-templator#readme) (by Geraint White)—Include markdown files in an HTML template
 - [`match`](https://github.com/IonicaBizau/match.js#readme)—Simplest way to create match memory games.
 - [`mdify`](https://github.com/IonicaBizau/mdify#readme)—Markdown helpers with metadata support.
 - [`mongof`](https://github.com/IonicaBizau/node-mongof)—Sync MongoDB collections with JSON files.
 - [`nodeice`](https://github.com/IonicaBizau/nodeice)—Another PDF invoice generator
 - [`np-init`](https://github.com/IonicaBizau/np-init#readme)—Easily start a npm package from scratch.
 - [`npmreserve`](https://github.com/IonicaBizau/npmreserve)—Reserve package names on NPM.
 - [`oargv`](https://github.com/IonicaBizau/node-oargv)—Turns an object into a bash command.
 - [`packy`](https://github.com/IonicaBizau/packy#readme)—Set default fields in your package.json files.
 - [`page-changed`](https://github.com/IonicaBizau/node-page-changed)—Call a function when the page body is changed.
 - [`parent-search`](https://github.com/IonicaBizau/node-parent-search)—Search files and folders in parent directories.
 - [`phantom-jquery`](https://github.com/IonicaBizau/phantom-jquery#readme)—Access DOM elements using jQuery in PhantomJS.
 - [`regarde`](https://github.com/IonicaBizau/regarde)—A tiny tool and library to watch commands.
 - [`share-term`](https://github.com/Share-Term/share-term#readme)—Share the terminal with your friends.
 - [`ship-release`](https://github.com/IonicaBizau/ship-release#readme)—Publish new versions on GitHub and npm with ease.
 - [`statique`](https://github.com/IonicaBizau/statique)—A Node.JS static server module with built-in cache options and route features.
 - [`streamp`](https://github.com/IonicaBizau/node-streamp)—mkdir -p combined with streams.
 - [`template-html`](https://github.com/grit96/template-html#readme) (by Geraint White)—Generate static HTML files from templates and content files
 - [`tester-init`](https://github.com/IonicaBizau/tester-init#readme)—Init tests for tester.
 - [`tilda`](https://github.com/IonicaBizau/tilda)—Tiny module for building command line tools.
 - [`tilda-init`](https://github.com/IonicaBizau/tilda-init#readme)—Init cli applications.
 - [`tinyreq`](https://github.com/IonicaBizau/tinyreq)—Tiny library for making http(s) requests.
 - [`tinyreq-cli`](https://github.com/IonicaBizau/tinyreq-cli#readme)—A cli tool for making http(s) requests. CLI for tinyreq.
 - [`tithe`](https://github.com/IonicaBizau/tithe)—Organize and track the tithe payments.
 - [`transformer`](https://github.com/IonicaBizau/transformer#readme)—Transform data using synchronous and asynchronous functions.
 - [`web-term`](https://github.com/IonicaBizau/web-term)—A full screen terminal in your browser.
 - [`wrabbit`](https://github.com/jillix/wrabbit) (by jillix)—Wrap scripts by providing the wrapping function.

## :scroll: License

[MIT][license] © [Ionică Bizău][website]

[patreon]: https://www.patreon.com/ionicabizau
[paypal-donations]: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=RVXDDLKKLQRJW
[donate-now]: http://i.imgur.com/6cMbHOC.png

[license]: http://showalicense.com/?fullname=Ionic%C4%83%20Biz%C4%83u%20%3Cbizauionica%40gmail.com%3E%20(http%3A%2F%2Fionicabizau.net)&year=2014#license-mit
[website]: http://ionicabizau.net
[contributing]: /CONTRIBUTING.md
[docs]: /DOCUMENTATION.md
