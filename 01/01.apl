#!/usr/local/bin/apl -s

⍝ TODO: branching, jumps

val ← { (10>⍵) ∧ (0≤⍵) } 
filto ← { (val ⍵) / ⍵ }
filt ← { ((10>⍵) ∧ (0≤⍵)) / ⍵ }
deco ← { 10 ⊥ filt (⍵-48) }
getnum ← { deco (⎕FIO[8] ⍵) }

⍝fact←{  ⍵≤1: 1 ⍵×∇ ⍵-1 }

f←⎕FIO[3] 'input-test' ⍝ fopen 'input-test' for read
'getting first number' 
getnum f
getnum f
getnum f
⎕FIO[10] f
'done'
l←⎕FIO[8] f       ⍝ fgets


⎕FIO[4] f         ⍝ fclose
l←l-48 ⍝ - '0' to get digits
valid ← (10>l) ∧ (0≤l) ⍝ get only valid decimal digits (0≤x<10)
num ← 10 ⊥ valid / l ⍝ decode the valid digits from l

num

filter ← { valid ← (10>⍵) ∧ (0≤⍵) }

(filter 1 2 ¯3 4 ) / 1 2 ¯3 4

parse ← { (10>⍵) ∧ (0≤⍵) } 

p2 ← { (parse ⍵) / ⍵ }
p3 ← { 10 ⊥ p2 ⍵ }
p3 1 2 ¯1 8

)OFF
