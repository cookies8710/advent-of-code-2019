#!/usr/local/bin/apl -s

⎕IO←0 ⍝ index from 0
DISPLAY ← {4⎕CR⍵}
GET_LINES ← {⎕FIO[49]⍵}

filename ← {⍵[0;]}⊃¯1↑⎕ARG

'Loading input from ', filename

⍝tree ← ('A' ('B' ('D' ⍬ ⍬) ('E' ⍬ ⍬)) ('C' ⍬ ⍬) ('G' ⍬ ⍬))

⍝'tree:'
⍝DISPLAY tree
⍝
⍝∇ print t
⍝  →(C E)[t≡⍬]
⍝  C:t[0]
⍝  print¨ 1↓t
⍝  E:→0
⍝∇
⍝
⍝halt ← 2
⍝∇ result ← add x; tree; node; newnode
⍝  (tree node newnode) ← x
⍝'ADD 1. tree: ' 
⍝4⎕CR tree
⍝'ADD 2. adding ',newnode,' under node ',node
⍝
⍝4⎕CR ⊃tree[0]
⍝4⎕CR node
⍝'ADD 2.5 is this node correct?', tree[0] ≡ node
⍝
⍝  tree ←  tree, (⊂newnode)
⍝
⍝'ADD 3. added; tree: ' 
⍝4⎕CR tree
⍝
⍝'ADD 4. ⊃tree[0]:'
⍝4⎕CR ⊃tree[0]
⍝'ADD 5. children:' 
⍝4⎕CR1↓tree
⍝
⍝halt←halt-1
⍝  →(0 C)[1⌊halt]
⍝C:
⍝  tree ← tree[0], {add (⊂⍵) node newnode}¨(1↓tree) 
⍝  result ← tree
⍝∇
⍝
⍝print tree

⍝DISPLAY add  ('A1' (,'A2') ) 'A1' 'B1'

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

'DEVE'
d edges
d process edges

lines ← GET_LINES 'input-test'
split←{{⍵[0]}(')'⍷⍵)/⍳⍴⍵}


n←split¨ lines
input_edges ←n {(⍺↑⍵) ((⍺+1)↓⍵)}¨ lines

cat ←⊃ ({⍵[0]}¨ input_edges), ({⍵[1]}¨ input_edges)

uniq ← {(~(((1↓⍵)=(¯1↓⍵)), 0))/⍵}
sorted←cat[⍋cat]

vertices ← ∪ cat
nvertices ← 0⌷⍴vertices

d vertices
edge_matrix ← nvertices nvertices ⍴ 0

∇ return ← vertex_index args
  return ← ((args⍷⊃vertices)[;0])/⍳⍴vertices
∇

∇ return ← create_matrix args
  i ← 0


L:
  (a b) ← (⊃0⌷⊃input_edges[i]) (⊃1⌷⊃input_edges[i])
  a ← {⍵[0]}vertex_index (,a)
  b ← {⍵[0]}vertex_index (,b)

  edge_matrix[a;b] ← 1
  edge_matrix[b;a] ← 1

  i ← i+1
  return←edge_matrix
  ⍎(i ≥ ⍴input_edges)/'→0'
  →L

∇

edge_matrix ← create_matrix input_edges

process edge_matrix

d edge_matrix


⍝ generates identity matrix of side ⍵
id_matrix ← {⍵ ⍵⍴1,⍵/0}

⍝ initial state - distance matrix with X (infinity) everywhere except main diagonal
x←X ∧ ~id_matrix nvertices
d x

d x∧edge_matrix
⍝x←(~id_matrix nvertices) ∧ edge_matrix ∨ 1000
 x[0;] ⌊ ({(1000 1)[⍵]}edge_matrix[1;])⌊ ({(1000 1)[⍵]}edge_matrix[3;])


'Done.'

)OFF
