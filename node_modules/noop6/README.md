
# noop6

 [![Patreon](https://img.shields.io/badge/Support%20me%20on-Patreon-%23e6461a.svg)][patreon] [![PayPal](https://img.shields.io/badge/%24-paypal-f39c12.svg)][paypal-donations] [![AMA](https://img.shields.io/badge/ask%20me-anything-1abc9c.svg)](https://github.com/IonicaBizau/ama) [![Version](https://img.shields.io/npm/v/noop6.svg)](https://www.npmjs.com/package/noop6) [![Downloads](https://img.shields.io/npm/dt/noop6.svg)](https://www.npmjs.com/package/noop6) [![Get help on Codementor](https://cdn.codementor.io/badges/get_help_github.svg)](https://www.codementor.io/johnnyb?utm_source=github&utm_medium=button&utm_term=johnnyb&utm_campaign=github)

> No operation as a module using an arrow function.

## :cloud: Installation

```sh
$ npm i --save noop6
```


## :clipboard: Example



```js
const noop = require("noop6");

noop();
// Nothing happened, yay!

let square = (x, cb) => {
    cb = cb || noop;
    cb(x * x);
};

square(42, r => {
    console.log(r);
    // => 1764
});

// No error, even we don't send the callback function
square(42);
```

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
 - [`assured`](https://github.com/IonicaBizau/assured#readme)—Combine promises and callbacks together.
 - [`asyncer.js`](https://github.com/IonicaBizau/asyncer.js#readme)—Run groups of (a)sync functions.
 - [`bloggify-ajs-renderer`](https://github.com/IonicaBizau/bloggify-ajs-renderer#readme)—ajs renderer for Bloggify.
 - [`custom-return`](https://github.com/IonicaBizau/custom-return#readme)—Generate a function that returns a constant.
 - [`fn-wrap`](https://github.com/IonicaBizau/fn-wrap#readme)—Function wrapping utility.
 - [`fortran`](https://github.com/IonicaBizau/node-fortran)—Fortran bridge for Node.js which allows you to run Fortran code from Node.js.
 - [`function.name`](https://github.com/IonicaBizau/function.name#readme)—Function name shim (especially for supporting function names in Internet Explorer).
 - [`lien`](https://github.com/LienJS/Lien)—Another lightweight NodeJS framework. Lien is the link between request and response objects.
 - [`lwipify`](https://github.com/IonicaBizau/lwipify#readme)—Convert images in lwip objects.
 - [`nodeice`](https://github.com/IonicaBizau/nodeice)—Another PDF invoice generator
 - [`pull-from-source`](https://github.com/IonicaBizau/pull-from-source#readme)—Pulls the changes from the source repository in the forked one.
 - [`tithe`](https://github.com/IonicaBizau/tithe)—Organize and track the tithe payments.
 - [`transformer`](https://github.com/IonicaBizau/transformer#readme)—Transform data using synchronous and asynchronous functions.

## :scroll: License

[MIT][license] © [Ionică Bizău][website]

[patreon]: https://www.patreon.com/ionicabizau
[paypal-donations]: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=RVXDDLKKLQRJW
[donate-now]: http://i.imgur.com/6cMbHOC.png

[license]: http://showalicense.com/?fullname=Ionic%C4%83%20Biz%C4%83u%20%3Cbizauionica%40gmail.com%3E%20(http%3A%2F%2Fionicabizau.net)&year=2016#license-mit
[website]: http://ionicabizau.net
[contributing]: /CONTRIBUTING.md
[docs]: /DOCUMENTATION.md
