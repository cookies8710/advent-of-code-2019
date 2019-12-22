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
  ⍎(n<0)/'n←n+deck_size'
  ⍎(index ≥ n)/'index←index-n◊→0'
  ⍎(index < n)/'index←index+deck_size-n◊→0'
∇

∇ return ← deal_with_increment inc
  return ← ⍬
  index ← deck_size|index×inc 
∇

index ← 2020
indices ← 2020

∇ main
  
  n ← 0
  hit ← 0
  L:
n
⊣{⍎input[⍵;]}¨⍳0⌷⍴ input

hit ← index ∊ indices
indices←indices,index
n←n+1
  ⍎(~hit)/'→L'
  n
∇

⍝main

index ← 2019
⊣{⍎input[⍵;]}¨⍳0⌷⍴ input
index


'Done.'
)OFF
