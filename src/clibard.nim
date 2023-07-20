## Google Bard CLI
import std/asyncdispatch
import std/strtabs
from std/cookies import parseCookies
from std/strutils import join
from std/os import sleep
from std/random import randomize, rand

import pkg/bard
import pkg/gookie

proc startNewBardChat: BardAiChat =
  echo "Trying to get your Google session"
  let cookies = parseCookies getGoogleCookies()
  if not (cookies.hasKey("__Secure-1PSID") and cookies.hasKey "__Secure-1PSIDTS"):
    quit "Cannot get session. Please login into Google account in browser"
  echo "Session successfully got!"
  echo "Creating new Google Bard instance"
  let ai = waitFor newBardAi(
    psid = cookies["__Secure-1PSID"],
    psidts = cookies["__Secure-1PSIDTS"]
  )
  echo "Google Bard instance sucessfully created!"
  result = newBardAiChat ai


proc typingEcho(s: string; instant = false; fast = false) =
  if instant:
    echo s
  else:
    for ch in s:
      stdout.write ch
      flushFile stdout
      sleep rand(
        if fast:
          case ch:
          of '\n': 10..50
          of ' ': 3..10
          else: 1..10
        else: 1..10
      )

proc cliPrompt(texts: seq[string]; instant = false; fast = false) =
  ## Prompts to Google Bard
  var chat = startNewBardChat()
  let text = texts.join " "
  try:
    let response = waitFor chat.prompt text
    echo "\l"
    typingEcho response.text, instant
  except BardExpiredSession:
    cliPrompt(@[text])

proc cliChat(instant = false; fast = false) =
  ## Start chat with Google Bard
  ## 
  ## Close with ".exit"
  var chat = startNewBardChat()
  echo "\l==Chat started==\l"
  while true:
    stdout.write "You: "
    let text = readLine stdin
    if text == ".exit":
      break
    try:
      let response = waitFor chat.prompt text
      stdout.write "Bard: "
      typingEcho response.text, instant
      echo "\l"
    except BardExpiredSession:
      cliPrompt(@[text])

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
