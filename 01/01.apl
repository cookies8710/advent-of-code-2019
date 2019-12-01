#!/usr/local/bin/apl -s

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
  →(CONT END)[1 + (eof f)]
  CONT: result ← result, locanum
  →READ
  END:
  null ← ⎕FIO[4] f ⍝ fclose ⍝ don't print fclose's result
∇

masses ← readall 'input'
compfuel ← { (⌊ ⍵ ÷ 3) - 2 }

∇ result ← totalfuel masses;p
  p ← 0 ⌈ compfuel masses
  nonnull ← (∨/ {⍵≠0} p)
  →(END CONT)[1 + nonnull]
  END: 
  result ← p
  → 0
  CONT: 
  result ← p + (totalfuel p)
∇

'Part 1 answer:', +/ compfuel masses
'Part 2 anser:', +/ totalfuel masses

)OFF
