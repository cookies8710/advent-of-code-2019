#!/usr/local/bin/apl -s

⎕IO←0 ⍝ index from 0
DISPLAY ← {4⎕CR⍵}
d←DISPLAY

GET_LINES ← {⎕FIO[49]⍵}

⍝ global variables 
(deck_size filename) ← ¯2↑⎕ARG
deck_size ← ⍎deck_size

'Loading input ', filename, ', deck size', deck_size
input ← ⊃GET_LINES filename

∇ return ← deal_into_new_stack
  return ← ⍬
  deck ← ⌽deck
∇

∇ return ← cut n
  return ← ⍬
  ⍎(n > 0)/'deck ← (n↓deck), (n↑deck)◊→0'
  ⍎(n < 0)/'deck ← (n↑deck), (n↓deck)◊→0'
∇

∇ return ← deal_with_increment inc
  return ← ⍬
  deck[{(0⌷⍴deck)|⍵×inc}¨⍳⍴deck] ← deck
∇

deck ← ⍳deck_size
⊣{⍎input[⍵;]}¨⍳0⌷⍴ input

'Part 1 answer:'
(2019⍷deck)/⍳deck_size


'Done.'
)OFF
