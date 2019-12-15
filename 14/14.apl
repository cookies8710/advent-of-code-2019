#!/usr/local/bin/apl -s

⎕IO←0 ⍝ index from 0
DISPLAY ← {4⎕CR⍵}
d←DISPLAY

GET_LINES ← {⎕FIO[49]⍵}

⍝ global variables 
filename ← {⍵[0;]}⊃¯1↑⎕ARG

'Loading input ', filename
input ← ⊃GET_LINES filename

∇ result ← reorder m;n;r;ch;t;tmp
  n ← 0⌷⍴m
O:
  r ← 0
  ch ← 0

L:
  t←(0>m[r;])/⍳n
  →(SWAP CONT)[t≡⍬]
  SWAP:
  ⍎(t=r)/'→CONT'
  tmp ← m[t;]
  m[t;] ← m[r;]
  m[r;] ← tmp
  ch ← 1
  CONT:
  r ← r + 1
  ⍎(r<n)/'→L'
  ⍎(ch≠0)/'→O'

result ← m
  
∇ 
∇ return←resolve args; rules; state; n
  (rules state)←args
  'resolve, rules:'
  d rules
  n←⍴state
  ore_index ← get_chemical_index 'ORE' ⍝-ore_index⌽
  ore_mask ← (-ore_index)⌽~(1,((n-1)/0))
  d ore_index
  L:
  state ← state + +⌿rules[(state > 0)/⍳n;]
  ⍎(∨/ore_mask∧(state>0))/'→L' ⍝ continue until there's a positive amount of anything other than ORE (assumed to be in index 0)
  return←ore_index⌷state
∇

∇ return ← vec args; amount; position; n
  (amount position n) ← args
  return ← n/0
  return[position] ← amount
∇

∇ return ← create_rule_vector args; dim; target; recipe
  (args dim) ← args 
  target ← 0⌷1↑args
  recipe ← 1↓args
  return ← -vec (⊃target),dim
  return ← return + ⊃+/{vec ⍵,dim}¨recipe
∇


⍝ extracts all occurrences of 'regex' in 'string'
∇ return ← extract args
  (regex string) ← args
  return ← {(⊢/⍵)↑(⊣/⍵)↓string}¨ regex ⎕RE['↓g'] string
∇

⍝ rows - decoded rules (N CHEMICAL)* where the last entry is target
rows ← {extract '\d+\s+[A-Z]+' input[⍵;]}¨⍳0⌷⍴input

⍝ all_chemicals - all chemicals from 'rows':w

all_chemicals ← ∪⊃,/{'[A-Z]+'⎕RE ⍵}¨rows

'# of chemicals:', (⍴all_chemicals),':'
d all_chemicals

∇ return ← get_chemical_index chemical
  return←0⌷((⊂,chemical)⍷all_chemicals)/⍳⍴all_chemicals
∇

⍝ parses ingredient string, e.g. '10 ABC' to doublet (quantity chemical_index) - e.g. (10 7)
∇ return ← parse_ingredient args;n;c;ns;ne;cs;ce
  (n  c) ← 2↓'(\d+)\s+([A-Z]+)'⎕RE['↓'] args
  (ns ne) ← n
  n←⍎ne↑ns↓args
  (cs ce) ← c
  c←ce↑cs↓args
  c←get_chemical_index c
  return ← n c  
∇

⍝ now - transform rows to rule recipes
n ← 0⌷⍴all_chemicals
parsed_recipes ← {⌽parse_ingredient¨⍵}¨ rows
m3 ←n n⍴⊃,/ (n/0), {create_rule_vector ⍵ n}¨ parsed_recipes

fuel_1_state ← n/0
fuel_1_state[get_chemical_index 'FUEL'] ← 1

m3 ← reorder m3

part1 ← resolve m3 fuel_1_state
'Solution: ', part1

'Done.'
)OFF
