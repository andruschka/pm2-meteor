
# function.name

 [![Patreon](https://img.shields.io/badge/Support%20me%20on-Patreon-%23e6461a.svg)][patreon] [![PayPal](https://img.shields.io/badge/%24-paypal-f39c12.svg)][paypal-donations] [![AMA](https://img.shields.io/badge/ask%20me-anything-1abc9c.svg)](https://github.com/IonicaBizau/ama) [![Version](https://img.shields.io/npm/v/function.name.svg)](https://www.npmjs.com/package/function.name) [![Downloads](https://img.shields.io/npm/dt/function.name.svg)](https://www.npmjs.com/package/function.name) [![Get help on Codementor](https://cdn.codementor.io/badges/get_help_github.svg)](https://www.codementor.io/johnnyb?utm_source=github&utm_medium=button&utm_term=johnnyb&utm_campaign=github)

> Function name shim (especially for supporting function names in Internet Explorer).

If the name field is not accessible (usually this happens on Internet Explorer), it will be defined.

## :cloud: Installation

```sh
$ npm i --save function.name
```


## :clipboard: Example



```js
const functionName = require("function.name");

function foo () {}

console.log(functionName(foo));
// => foo
```

## :memo: Documentation


### `functionName(input)`
Get the function name.

#### Params
- **Function** `input`: The input function.

#### Return
- **String** The function name.



Usually, you will **not** use this as function but you will access the `name` field on the function directly.

## :yum: How to contribute
Have an idea? Found a bug? See [how to contribute][contributing].


## :moneybag: Donations

Another way to support the development of my open-source modules is
to [set up a recurring donation, via Patreon][patreon]. :rocket:

[PayPal donations][paypal-donations] are appreciated too! Each dollar helps.

Thanks! :heart:

## :dizzy: Where is this library used?
If you are using this library in one of your projects, add it in this list. :sparkles:


 - [`typpy`](https://github.com/IonicaBizau/typpy)—A better typeof for JavaScript.

## :scroll: License

[MIT][license] © [Ionică Bizău][website]

[patreon]: https://www.patreon.com/ionicabizau
[paypal-donations]: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=RVXDDLKKLQRJW
[donate-now]: http://i.imgur.com/6cMbHOC.png

[license]: http://showalicense.com/?fullname=Ionic%C4%83%20Biz%C4%83u%20%3Cbizauionica%40gmail.com%3E%20(http%3A%2F%2Fionicabizau.net)&year=2016#license-mit
[website]: http://ionicabizau.net
[contributing]: /CONTRIBUTING.md
[docs]: /DOCUMENTATION.md
