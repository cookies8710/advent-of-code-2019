#!/usr/local/bin/apl -s

⎕IO←0

dbl ← {∨/(¯1↓⍵)=(1↓⍵)} ⍝ checking for doublets shift by one and compare with itself
nd ← {∧/⍵=⍵[⍋⍵]} ⍝ nondecreasing test - number is not decreasing if it's the same as when it's digits are sorted in ascending order

(s e)←(240298 784956)
nums ← s + ⍳1+e-s ⍝ numbers to check
matching ← {(dbl ⍵) ∧ (nd ⍵)}¨  ⍕¨ nums ⍝ pick all numbers that have doublet and have nondecreasing digits
passwords ← matching / nums

⍝ Second part doublet filter - "true" doublet will manifest  as 0 1 0 inside the string or 1 0, 0 1 in the beginning or end respectively
dbl2 ← {∨/(∨/0 1 0⍷⍵) (∧/1 0=2↑⌽⍵) (∧/1 0=2↑⍵)}

'Part 1 answer:', ⍴passwords
'Part 2 answer:', +/ {dbl2 (¯1↓⍵)=(1↓⍵)}¨ ⍕¨ passwords

)OFF
