#!/usr/local/bin/apl -s

⎕IO←0 ⍝ index from 0
DISPLAY ← {4⎕CR⍵}
GET_LINES ← {⎕FIO[49]⍵}

∇dbg a
 a,':'
 DISPLAY ⍎a
∇

filename ← {⍵[0;]}⊃¯1↑⎕ARG

'Loading input from ', filename

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
⍝EDGE2 ← { {mat[⍵[0];⍵[1]]←1}¨ {(⍵[0] ⍵[1]) (⍵[1] ⍵[0])} (1↓⍵)}

⍝mat ← GRAPH 'a' 'b' 'c' 'd' 'e'
⍝mat ← EDGE mat (1 2)
⍝mat + mat



edges ← 4 4 ⍴ 0 1 1 0 1 0 0 0 1 0 0 1 0 0 1 0

∇ ret ← comp args; mat; edges; i; j; ij
  (mat edges ij) ← args
 
  (i j)←(ij[0] ij[1])

  ret ← mat
  ⍎(mat[i;j]=X)/'→0'

  len ← 1↑⍴edges

  f←mat[i;j]+edges[j;]
  mat[i;(f/⍳len)]←mat[i;j]+1 

  ret ← mat
∇

∇ ret ← apply args;mat;edges
  (mat edges)←args
  ret ←  ⌊/⌊/{comp mat edges ⍵}¨⍳⍴edges
∇

  d←DISPLAY
  X ← 10000
∇ ret ← process edges; mat
  mat← (⍴edges)⍴X
  
  ⊣{mat[⍵;⍵]←0}¨ (⍳0⌷⍴edges) 
  LOOP:
  mat←⊃apply mat edges
  ⍎(X∊mat)/'→LOOP'
  ret ← mat
∇

lines ← GET_LINES filename
split←{{⍵[0]}(')'⍷⍵)/⍳⍴⍵}


n←split¨ lines
input_edges ←n {(⍺↑⍵) ((⍺+1)↓⍵)}¨ lines

cat ←⊃ ({⍵[0]}¨ input_edges), ({⍵[1]}¨ input_edges)

uniq ← {(~(((1↓⍵)=(¯1↓⍵)), 0))/⍵}
sorted←cat[⍋cat]

vertices ← ∪ cat
nvertices ← 0⌷⍴vertices

edge_matrix ← nvertices nvertices ⍴ 0

∇ return ← vertex_index args
  return ← ¯1↑((args⍷⊃vertices)[;0])/⍳⍴vertices
∇

∇ return ← create_matrix args; input_edges
  input_edges ← args
  i ← 0

L:
  (a b) ← (⊃0⌷⊃input_edges[i]) (⊃1⌷⊃input_edges[i])
  a ← {⍵[0]}vertex_index (,a)
  b ← {⍵[0]}vertex_index (,b)

 ⍝ edge_matrix[a;b] ← 1
  edge_matrix[b;a] ← 1

  i ← i+1
  return←edge_matrix
  ⍎(i ≥ ⍴input_edges)/'→0'
  →L

∇

'Creating edge matrix for' nvertices 'vertices'
edge_matrix ← create_matrix input_edges
'Edge matrix created'
d edge_matrix

⍝ generates identity matrix of side ⍵
id_matrix ← {⍵ ⍵⍴1,⍵/0}

⍝ initial state - distance matrix with X (infinity) everywhere except main diagonal
proximity_matrix←X ∧ ~id_matrix nvertices
proximity_matrix←proximity_matrix∨edge_matrix ⍝ initial edges - direct neighbours

∇ result ← resolve matrix
  L:
  matrix←matrix⌊.+⍉matrix
  ⍎(X∊matrix)/'→L'
  result ← matrix
∇

∇ result ← resolve2 matrix;m2
  m2 ← matrix
  L:
  matrix ← m2 
  m2←matrix⌊.+matrix
'changes:',+/+/m2≠matrix
  ⍎(∨/∨/m2≠matrix)/'→L'
  result ← matrix
∇

'resolving'
proximity_matrix ← resolve2 proximity_matrix
'sum of first column of proximity matrix:'
+/proximity_matrix[;0]

⍝d proximity_matrix
proximity_matrix[(vertex_index (,'YOU'));]

d (nvertices⍴proximity_matrix[(vertex_index (,'SAN'));] ∧ edge_matrix[(vertex_index (,'SAN'));])/vertices

'Done.'

)OFF
