## Google Bard CLI
import std/asyncdispatch
from std/strutils import join
from std/os import sleep
from std/random import randomize, rand
from std/strformat import fmt
from std/sugar import collect

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
    if cookies.hasKey "__Secure-1PSID":
      if not silent:
        echo fmt"Trying '{cookies.context}' cookies..."
      if not silent and not cookies.hasKey "__Secure-1PSIDTS":
        echo fmt"Warning, without '__Secure-1PSIDTS' cookie, probably it won't work."
      try:
        let ai = waitFor newBardAi $cookies
        if not silent:
          echo "Google Bard instance successfully created!\n"
        return newBardAiChat ai
      except BardCantGetSnlm0e, BardCantGetCfb2h:
        echo fmt"Cannot login with '{cookies.context}' cookies"
    else:
      if not silent:
        echo fmt"Not logged in at '{cookies.context}' (or needed cookies aren't available)"
  quit "Cannot get session. Check if your Google account is logged in or try another one."


proc typingEcho(s: string; instant = false; fast = false) =
  if instant and not fast:
    stdout.write s
  else:
    for ch in s:
      stdout.write ch
      flushFile stdout
      sleep rand(
        if not fast:
          case ch:
          of '\n': 70..120
          of ' ': 30..60
          else: 10..20
        else: 1..5
      )
  echo ""

proc handleUnrecognizableResp =
  let err = getCurrentException()
  if err.name == $BardUnrecognizedResp:
    echo err.msg


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

proc cliChat(instant = false; fast = false; silent = false; extraInfo = true) =
  ## Start chat with Google Bard
  ## 
  ## Close with "exit"
  var chat = startNewBardChat silent
  echo "==Chat started==\l"
  var lastDrafts: seq[BardAiResponseDraft]
  block loop:
    while true:
      block prompt:
        stdout.write "You: "
        let text = readLine stdin
        if text.len > 0:
          if text == "exit":
            break loop
          if text.len > 2 and text[0..2] == "rc_":
            for draft in lastDrafts:
              if text == draft.id:
                stdout.write "Bard draft: "
                typingEcho(draft.text, instant, fast)
                echo ""
                break prompt
            echo "Draft not found.\l"
            break prompt

          try:
            let response = waitFor chat.prompt text
            lastDrafts = response.drafts
            stdout.write "Bard: "
            typingEcho(response.text, instant, fast)
            if extraInfo:
              echo "---"
              echo "Related: " & collect(for srx in response.relatedSearches: fmt"'{srx}'").join ", "
              echo "Cached drafts: " & collect(for draft in response.drafts: fmt"'{draft.id}'").join ", "
            echo ""
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
