#!/usr/local/bin/apl -s

⎕IO←0 ⍝ index from 0
DISPLAY ← {4⎕CR⍵}
GET_LINES ← {⎕FIO[49]⍵}

⍝ global variables 
filename ← {⍵[0;]}⊃¯1↑⎕ARG

'Loading input ', filename

input ← ⊃GET_LINES filename

d ← DISPLAY 
(h w) ← ⍴input

'Loaded map' w '×' h ':'
d input

∇ return←gcd args; a; b
  (a b) ← args
  return ← a
  ⍎(a=b)/'→0'
  →(A B)[a<b]
  A: return←gcd (a-b) b
  →0
  B:return←gcd a (b-a)
  →0
∇

asteroids←'#'⍷input

d asteroids

∇ return ← valid_coords args; map; x; y; lx; ly
  (map pos) ← args
  (x y) ← ⊃pos
  (ly lx) ← ⍴map

  return ← 0
  ⍎(∨/ (x<0) (y<0) (x ≥ lx) (y ≥ ly))/'→0'

  return ← 1
∇

∇ return ← gen_invi args; map; posa; posb; x; y; k
  (map posa posb) ← args
  return ← map
  (x y) ← posb
  ⍎(~map[y;x])/'→0'

  return ← (⍴map)⍴1
  vector ← posb - posa

  ⍎(∧/ vector = (0 0))/'→0'

  ⍎(∧/{⍵≠0}¨vector)/'divisor ← gcd (|vector)'
  ⍎(~∧/{⍵≠0}¨vector)/'divisor ← +/|vector'

  vector ← vector ÷ divisor

  k ← 1
  L:
  position ← posb + k×vector
  ⍎(~valid_coords map position)/'→0'

  return[(position[1]); (position[0])] ← 0

  k ← k + 1
  → L
∇

∇ return ← visibility_from args; map; pos; x; y; tmp
  (map pos) ← args
  (x y) ← ⊃pos

  tmp ← (⍴map)⍴1

  ⊣{tmp ← tmp ∧ gen_invi map (x y) ⍵}¨((×/⍴map)⍴⍳⌽⍴map)
  return ← tmp
∇

∇ return ← number_of_visible_from args; map; pos
  (map pos) ← args
  return ← 0
  ⍎(~map[pos[1];pos[0]])/'→0'
  return ← ¯1 + +/+/ map ∧ visibility_from map pos
∇


visibility_matrix ← (⍳h) ∘.{number_of_visible_from asteroids (⍵ ⍺)} ⍳w
part1 ← ⌈/⌈/ visibility_matrix
'Part 1:' part1

'Done.'
)OFF
