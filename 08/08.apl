#!/usr/local/bin/apl -s

⎕IO←0 ⍝ index from 0
DISPLAY ← {4⎕CR⍵}
GET_LINES ← {⎕FIO[49]⍵}

⍝ global variables 
filename ← {⍵[0;]}⊃¯1↑⎕ARG

'Loading input ', filename

input ← ⍎¨⊃{⍵[0]}GET_LINES filename

(w t) ← 25 6
layers ← (⍴input)÷×/w t
'The images has' layers 'layers'

∇r←fun args;i;w;t;data;s
 (i w t data)←args
 s←w×t
 r ← t w⍴s↑(i×s)↓data
∇

⍝ extract layers from input
layers ← {fun ⍵ w t input}¨ ⍳layers 

⍝ for each layer compute number of 0s, 1s, 2s
zeros ← {+/+/0⍷⍵}¨layers
ones ← {+/+/1⍷⍵}¨layers
twos ← {+/+/2⍷⍵}¨layers
 
'Part 1:', (1↑(⍳⍴zeros)[⍋zeros]) ⌷ ones × twos

'Done.'
)OFF
