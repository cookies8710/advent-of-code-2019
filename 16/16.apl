#!/usr/local/bin/apl -s

⎕IO←0 ⍝ index from 0
DISPLAY ← {4⎕CR⍵}
d←DISPLAY

GET_LINES ← {⎕FIO[49]⍵}

⍝ global variables 
filename ← {⍵[0;]}⊃¯1↑⎕ARG

'Loading input ', filename
input ← ⊃GET_LINES filename
input ← input[0;]

output_pattern←{1↓(1+⍴input)⍴(⍵+1)/0 1 0 ¯1}

∇ return ← execute args
  (in n) ← args
  i ← 0
  op ← ⊃output_pattern¨⍳⍴in
  L:
  'step ' i '/' n
   in_digits ← ⍎¨in
   in ← ⊃,/⍕¨10||in_digits+.×op
   i ← i + 1
  ⍎(i < n)/'→L'
  return ← in
∇

d input
d ⍴input
d 8↑execute input 100


'Part 2:'
skip ← ⍎7↑input

rem ←(10000-⌈skip÷⍴input)
tail ← (-⍴input)+(⍴input)|skip
input ← (tail↑input), ⊃,/rem/⊂input

result ← execute input 100
d 8↑result
'Done.'
)OFF
