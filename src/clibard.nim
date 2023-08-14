## Google Bard CLI
import std/asyncdispatch
from std/strutils import join, repeat
from std/os import sleep
from std/random import randomize, rand
from std/strformat import fmt
from std/sugar import collect
# from std/terminal import 
import std/terminal

import pkg/bard
import pkg/gookie

var testedSessions: seq[string]

proc startNewBardChat(debugLog = false): BardAiChat =
  if debugLog:
    echo "Trying to get your Google sessions"
  let cookiesList = getGoogleCookies()
  for cookies in cookiesList:
    if cookies.context in testedSessions:
      if debugLog:
        echo fmt"Skipping '{cookies.context}' because it didn't worked."
      continue
    testedSessions.add cookies.context
    if cookies.hasKey "__Secure-1PSID":
      if debugLog:
        echo fmt"Trying '{cookies.context}' cookies..."
      if debugLog and not cookies.hasKey "__Secure-1PSIDTS":
        echo fmt"Warning, without '__Secure-1PSIDTS' cookie, probably it won't work."
      try:
        let ai = waitFor newBardAi $cookies
        if debugLog:
          echo "Google Bard instance successfully created!\n"
        return newBardAiChat ai
      except BardCantGetSnlm0e, BardCantGetCfb2h:
        echo fmt"Cannot login with '{cookies.context}' cookies"
    else:
      if debugLog:
        echo fmt"Not logged in at '{cookies.context}' (or needed cookies aren't available)"
  styledEcho fgRed, "Cannot get session. Check if your Google account is logged in or try another one."
  quit 1


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
    styledEcho fgRed, err.msg


proc cliPrompt(texts: seq[string]; instant = true; fast = false; debugLog = false) =
  ## Prompts to Google Bard
  var chat = startNewBardChat debugLog
  let text = texts.join " "
  if text.len > 0:
    try:
      let response = waitFor chat.prompt text
      typingEcho(response.text, instant, fast)
    except BardExpiredSession, BardUnrecognizedResp:
      handleUnrecognizableResp()
      cliPrompt(@[text], instant, fast, debugLog)

proc cliChat(instant = false; fast = false; debugLog = false; extraInfo = true) =
  ## Start chat with Google Bard
  ## 
  ## Close with "exit"
  var chat = startNewBardChat debugLog
  styledEcho styleReverse, "==Chat started==", bgDefault, "\l"
  var lastDrafts: seq[BardAiResponseDraft]
  block loop:
    while true:
      block prompt:
        stdout.styledWrite fgGreen, "You: "
        let text = readLine stdin
        if text.len > 0:
          if text == "exit":
            break loop
          if text.len > 2 and text[0..2] == "rc_":
            for draft in lastDrafts:
              if text == draft.id:
                stdout.styledWrite fgMagenta, "Bard draft: "
                typingEcho(draft.text, instant, fast)
                echo ""
                break prompt
            echo "Draft not found.\l"
            break prompt

          try:
            let response = waitFor chat.prompt text
            lastDrafts = response.drafts
            stdout.styledWrite fgBlue, "Bard: "
            typingEcho(response.text, instant, fast)
            if extraInfo:
              echo "-".repeat terminalWidth()
              styledEcho fgBlue, styleDim, "Related: ", fgDefault, collect(for srx in response.relatedSearches: fmt"'{srx}'").join ", "
              styledEcho fgBlue, styleDim, "Cached drafts: ", fgDefault, collect(for draft in response.drafts: fmt"'{draft.id}'").join ", "
              echo "-".repeat terminalWidth()
            echo ""
          except BardExpiredSession, BardUnrecognizedResp:
            handleUnrecognizableResp()
            cliPrompt(@[text], false, fast, debugLog)

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
