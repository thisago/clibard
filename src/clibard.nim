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

template withBardChat(body: untyped): untyped =
  ## Run code with authenticated Bard session
  try:
    body
  except Exception:
    chat = startNewBardChat()

proc typingEcho(s: string) =
  for ch in s:
    stdout.write ch
    flushFile stdout
    case ch:
    of '\n': sleep rand 300..600
    of ' ': sleep rand 50..200
    else: sleep rand 20..70

proc cliPrompt(texts: seq[string]) =
  ## Prompts to Google Bard
  var chat = startNewBardChat()
  let text = texts.join " "
  withBardChat:
    let response = waitFor chat.prompt text
    typingEcho response.text

proc cliChat =
  ## Start chat with Google Bard
  ## 
  ## Close with ".exit"
  var chat = startNewBardChat()
  while true:
    stdout.write "\lYou: "
    let text = readLine stdin
    if text == ".exit":
      break
    withBardChat:
      let response = waitFor chat.prompt text
      stdout.write "\lBard: "
      typingEcho response.text

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
