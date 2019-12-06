#!/usr/local/bin/apl -s

⎕IO←0 ⍝ index from 0
DISPLAY ← {4⎕CR⍵}
GET_LINES ← {⎕FIO[49]⍵}

filename ← {⍵[0;]}⊃¯1↑⎕ARG

'Loading input from ', filename

tree ← ('A' ('B' ('D' ⍬ ⍬) ('E' ⍬ ⍬)) ('C' ⍬ ⍬) ('G' ⍬ ⍬))

'tree:'
DISPLAY tree

∇ print t
  →(C E)[t≡⍬]
  C:t[0]
  print¨ 1↓t
  E:→0
∇

halt ← 2
∇ result ← add x; tree; node; newnode
  (tree node newnode) ← x
'ADD 1. tree: ' 
4⎕CR tree
'ADD 2. adding ',newnode,' under node ',node

4⎕CR ⊃tree[0]
4⎕CR node
'ADD 2.5 is this node correct?', tree[0] ≡ node

  tree ←  tree, (⊂newnode)

'ADD 3. added; tree: ' 
4⎕CR tree

'ADD 4. ⊃tree[0]:'
4⎕CR ⊃tree[0]
'ADD 5. children:' 
4⎕CR1↓tree

halt←halt-1
  →(0 C)[1⌊halt]
C:
  tree ← tree[0], {add (⊂⍵) node newnode}¨(1↓tree) 
  result ← tree
∇

print tree

DISPLAY add  ('A1' (,'A2') ) 'A1' 'B1'


∇ result ← GRAPH args
  n ← {⍵[0]}⍴args
  result ← n n⍴0
∇

∇ result ← EDGE args; matrix; nodes
  (matrix nodes) ← args
DISPLAY nodes
  {matrix[⍵[0];⍵[1]]←1}¨ {(⍵[0] ⍵[1]) (⍵[1] ⍵[0])} nodes
  result ← matrix
∇
⍝EDGE ← { {mat[⍵[0];⍵[1]]←1}¨ {(⍵[0] ⍵[1]) (⍵[1] ⍵[0])} ⍵}
EDGE2 ← { {mat[⍵[0];⍵[1]]←1}¨ {(⍵[0] ⍵[1]) (⍵[1] ⍵[0])} (1↓⍵)}

mat ← GRAPH 'a' 'b' 'c' 'd' 'e'
mat ← EDGE mat (1 2)
mat + mat

GET_LINES ← {⎕FIO[49]⍵}

lines ← GET_LINES 'input-test'
split←{{⍵[0]}(')'⍷⍵)/⍳⍴⍵}

n←split¨ lines
s2 ←n {(⍺↑⍵) ((⍺+1)↓⍵)}¨ lines
DISPLAY ⊃s2

cat ←⊃⊃ ({⍵[0]}¨ s2), ({⍵[1]}¨ s2)

uniq ← {(~(((1↓⍵)=(¯1↓⍵)), 0))/⍵}
{(1↓⍵)=(¯1↓⍵)} cat[⍋cat;]
sorted ← cat[⍋cat;]

'Done.'

)OFF
