## Google Bard CLI
import std/asyncdispatch
import std/strtabs
from std/cookies import parseCookies
from std/strutils import join
from std/os import sleep
from std/random import randomize, rand

import pkg/bard
import pkg/gookie

proc startNewBardChat(silent = false): BardAiChat =
  if not silent:
    echo "Trying to get your Google session"
  let cookies = parseCookies getGoogleCookies()
  if not (cookies.hasKey("__Secure-1PSID") and cookies.hasKey "__Secure-1PSIDTS"):
    quit "Cannot get session. Please login into Google account in browser"
  if not silent:
    echo "Session successfully got!"
    echo "Creating new Google Bard instance"
  let ai = waitFor newBardAi(
    psid = cookies["__Secure-1PSID"],
    psidts = cookies["__Secure-1PSIDTS"]
  )
  if not silent:
    echo "Google Bard instance successfully created!\n"
  result = newBardAiChat ai


proc typingEcho(s: string; instant = false; fast = false) =
  if instant and not fast:
    echo s
  else:
    for ch in s:
      stdout.write ch
      flushFile stdout
      sleep rand(
        if not fast:
          case ch:
          of '\n': 60..100
          of ' ': 20..60
          else: 10..30
        else: 1..5
      )

proc cliPrompt(texts: seq[string]; instant = true; fast = false; silent = true) =
  ## Prompts to Google Bard
  var chat = startNewBardChat silent
  let text = texts.join " "
  try:
    let response = waitFor chat.prompt text
    typingEcho(response.text, instant, fast)
  except BardExpiredSession:
    cliPrompt(@[text], instant, fast, silent)

proc cliChat(instant = false; fast = false; silent = false) =
  ## Start chat with Google Bard
  ## 
  ## Close with "exit"
  var chat = startNewBardChat silent
  echo "==Chat started==\l"
  while true:
    stdout.write "You: "
    let text = readLine stdin
    if text == "exit":
      break
    try:
      let response = waitFor chat.prompt text
      stdout.write "Bard: "
      typingEcho(response.text, instant, fast)
      echo "\l"
    except BardExpiredSession:
      cliPrompt(@[text], false, fast, silent)

when isMainModule:
  import pkg/cligen
  randomize()
  dispatchMulti([
    cliPrompt,
    cmdName = "prompt"
  ], [
    cliChat,
    cmdName = "chat"
  ])
