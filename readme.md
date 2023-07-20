<div align=center>

# clibard

#### Command line interface for Google Bard

**[About](#about) - [Setup](#setup) - [Usage](#usage)** - [License](#license)

</div>

## About

See this app in action here:
- [`clibard prompt`][promptVideo]
- [`clibard chat`][chatVideo]

This is a Google Bard CLI application interface.

Core libs used

- [Google Bard](https://github.com/thisago/bard) - Google Bard batchexecute implementation
- [Gookie](https://github.com/thisago/gookie) - Google cookie getter

## Setup

You can install using nimble, the [Nim](https://nim-lang.org) package manager:

```bash
nimble install clibard
```

To Gookie be able to get your Google session, you'll need to install an client
extension in your browser.
See the [tutorial at Gookie repository](https://github.com/thisago/gookie#usage)

Now, just [login into your Google account](https://accounts.google.com) and keep
open the browser

## Usage

**Help**

```
$ clibard --help

Google Bard CLI
Usage:
  clibard {SUBCMD}  [sub-command options & parameters]
where {SUBCMD} is one of:
  help    print comprehensive or per-cmd help
  prompt  Prompts to Google Bard
  chat    Start chat with Google Bard
```

The usage is very simple:

[**Single prompt**][promptVideo]

```bash
clibard prompt "what is ram memory?"
```

[**Chat**][chatVideo]

```bash
clibard chat
```

## License

This CLI application is open source, licensed over GPL-3

[promptVideo]: https://asciinema.org/a/b7rYNqm3iuqhT4kb7spy8PnSI
[chatVideo]: https://asciinema.org/a/SF2geUHJwsBgbSdrOgvME0ZLS
