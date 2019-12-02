#!/usr/local/bin/apl -s

⎕IO←0 ⍝ index from 0

val ← { (10>⍵) ∧ (0≤⍵) } 
filto ← { (val ⍵) / ⍵ }
filt ← { ((10>⍵) ∧ (0≤⍵)) / ⍵ }
deco ← { 10 ⊥ filt (⍵-48) }
getnum ← { deco (⎕FIO[8] ⍵) } ⍝ fgets

∇ result ← eof file
  result ← ⎕FIO[10] file ⍝ feof
∇  

⍝ read all numbers from file (currently only integer ≥ 0)
∇ result ← readall filename
  result ← ⍬
  f ← ⎕FIO[3] filename ⍝ fopen
  READ:
  locanum ← getnum f
  →(CONT END)[eof f]
  CONT: result ← result, locanum
  →READ
  END:
  null ← ⎕FIO[4] f ⍝ fclose ⍝ don't print fclose's result
∇

masses ← readall 'input'
compfuel ← { 0 ⌈ (⌊ ⍵ ÷ 3) - 2 }

∇ result ← totalfuel masses;p
  p ← compfuel masses
  nonnull ← (∨/ {⍵≠0} p)
  →(END CONT)[nonnull]
  END: 
  result ← p
  → 0
  CONT: 
  result ← p + (totalfuel p)
∇

'Part 1 answer:', +/ compfuel masses
'Part 2 answer:', +/ totalfuel masses

)OFF
