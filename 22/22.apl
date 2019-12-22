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
  index ← deck_size - index + 1
∇

∇ return ← cut n; tmp
  return ← ⍬

  →(POS NEG)[n < 0]
  POS:
  ⍎(index ≥ n)/'index←index-n◊→0'
  ⍎(index < n)/'index←index+deck_size-n◊→0'
  →END

  NEG:
  ⍎(index ≥ deck_size + n)/'index←index-(deck_size + n)◊→0'
  ⍎(index < deck_size + n)/'index←index-n◊→0'
  →END

END:
  index ← tmp
∇

∇ return ← deal_with_increment inc
  return ← ⍬
  index ← deck_size|index×inc 
∇

index ← 2019
⊣{⍎input[⍵;]}¨⍳0⌷⍴ input
'Part 1 answer:', index

'Done.'
)OFF
