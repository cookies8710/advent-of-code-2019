#!/usr/local/bin/apl -s

⎕IO←0

⍝ right2
∇result←r2 data
dim ← data[0]
x ← data[1] +1
y ← data[2]
l ← data[3] 
mat←dim dim⍴0
mat[y;]←(x/0),(l/1),((+/ (-x) (-l) dim)/0)
result←mat
∇

'calling r2'
r2 10 1 1 4
r2 10 0 7 5

∇result←l2 data
result←r2 data[0] ((data[1]-data[3])-1) data[2] data[3]
∇

∇result←u2 data
result ← ⍉r2 data[0] data[2] data[1] data[3]
∇

∇result←d2 data
result←u2 data[0] data[1] ((data[2]-data[3])-1) data[3]
∇
'last'
d2 11 9 7 6
'R8,U5,L5,D3'
DIM ← 10
first←(r2 DIM 0 0 8) + (u2 DIM 8 0 5) + (l2 DIM 8 5 5) + (d2 DIM 3 5 3)

'U7,R6,D4,L4'
second←(u2 DIM 0 0 7) + (r2 DIM 0 7 6) + (d2 DIM 6 7 4) + (l2 DIM 6 3 4)

⍝ find intersections
2 ⍷ first + second

)OFF
