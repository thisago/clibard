## Google Bard CLI
import std/asyncdispatch
from std/strutils import join
from std/os import sleep
from std/random import randomize, rand
from std/strformat import fmt

import pkg/bard
import pkg/gookie

var testedSessions: seq[string]

proc startNewBardChat(silent = false): BardAiChat =
  if not silent:
    echo "Trying to get your Google sessions"
  let cookiesList = getGoogleCookies()
  for cookies in cookiesList:
    if cookies.context in testedSessions:
      if not silent:
        echo fmt"Skipping '{cookies.context}' because it didn't worked."
      continue
    testedSessions.add cookies.context
    if (cookies.hasKey("__Secure-1PSID") and cookies.hasKey "__Secure-1PSIDTS"):
      if not silent:
        echo fmt"Trying '{cookies.context}' cookies..."
      try:
        let ai = waitFor newBardAi(
          psid = cookies["__Secure-1PSID"],
          psidts = cookies["__Secure-1PSIDTS"]
        )
        if not silent:
          echo "Google Bard instance successfully created!\n"
        return newBardAiChat ai
      except BardCantGetSnlm0e:
        echo fmt"Cannot login with '{cookies.context}' cookies"
    else:
      if not silent:
        echo fmt"Not logged in at '{cookies.context}' (or needed cookies aren't available)"
  quit "Cannot get session. Check if your Google account is logged in or try another one."


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

proc handleUnrecognizableResp =
  let err = getCurrentException()
  if err.name == $BardUnrecognizedResp:
    echo "Bard sent an unrecognizable response: " & err.msg


proc cliPrompt(texts: seq[string]; instant = true; fast = false; silent = true) =
  ## Prompts to Google Bard
  var chat = startNewBardChat silent
  let text = texts.join " "
  if text.len > 0:
    try:
      let response = waitFor chat.prompt text
      typingEcho(response.text, instant, fast)
    except BardExpiredSession, BardUnrecognizedResp:
      handleUnrecognizableResp()
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
    if text.len > 0:
      if text == "exit":
        break
      try:
        let response = waitFor chat.prompt text
        stdout.write "Bard: "
        typingEcho(response.text, instant, fast)
        echo "\l"
      except BardExpiredSession, BardUnrecognizedResp:
        handleUnrecognizableResp()
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
