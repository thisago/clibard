<div align=center>

# clibard

#### Command line interface for Google Bard

**[About](#about) - [Usage](#usage)** - [License](#license)

</div>

## About

This is a Google Bard CLI application interface.

Core libs used

- [Google Bard](https://github.com/thisago/bard) - Google Bard batchexecute implementation
- [Gookie](https://github.com/thisago/gookie) - Google cookie getter

## Setup

You can install using nimble, the [Nim](https://nim-lang.org) package manager:
```bash
nimble install clibard
# or
nimble install https://github.com/thisago/clibard
```

To Gookie be able to get your Google session, you'll need to install an client
userscript in your browser: [client.user.js](https://github.com/thisago/gookie/blob/master/src/client.user.js)

> **Note**
> You need a userscript manager extension in your web browser

Now, just [login into your Google account](https://accounts.google.com) and keep open an [Google homepage](https://www.google.com) tab.

## Usage

**Help**

```bash
clibard --help
```
<!-- 
The usage is very simple:

```bash
clibard prompt 
``` -->

## License

This CLI application is open source, licensed over GPL-3
