#!/usr/local/bin/apl -s

⎕IO←0

⍝ todo - DIM based on output 
⍝ todo - permit wires in negative coordinates

⍝ unit vectors
R←{⍵×(1 0)}
L←{⍵×(-1 0)}
U←{⍵×(0 1)}
D←{⍵×(0 (-1))}

origin←5 5
DIM ← 15

⍝ parses path string to vectors str -> vector vector vector ...
∇result←s1parse str 
  ⍝ split by ,
  i←¯1,((','⍷str)/⍳⍴str),(⍴str)
  ⍝ extract parts - R1 U2 etc
  parts←{⍵ {((⊢/⍺)-(1+⊣/⍺))↑(1+⊣/⍺)↓⍵} str}¨ {2↑⍵↓i}¨ ⍳(¯1+⍴i)
  ⍝ insert space after first character and map execute
  result ← ⍎¨ {⍵[0],' ',(1↓⍵)}¨ parts
∇

⍝ generates partial matrix for given position an vector
⍝ dim pos vec → mat
∇result←gen x
 dim←x[0]
 pos←⊃x[1]
 vec←⊃x[2]
 result←(dim dim)⍴0
 len←⌈/|⊃vec
 unit←vec÷len
 allpos←{⊃pos+⍵}¨ {⍵×unit}¨(⍳(len+1))
 ⊣{result[(⊢/⍵);(⊣/⍵)]←1}¨ allpos  
∇

⍝ draws path
∇result←draw d 
 v←⊃d[0]
 p←⊃d[1]
 result←1⌊+/ {gen DIM (p[⍵]) (v[⍵])}¨ ⍳⍴v
∇

⍝ parses path string and draws it
∇result ← complete strs
vectors←s1parse strs
result ← draw vectors ((⊂0 0),(+\vectors))
∇

⍝ draws all (both) wires and find the intersection closest to origin
∇result←solve wires
  sum ← ⊃⊃+/ complete¨ wires ⍝ todo why ⊃⊃
  4⎕CRsum
  results←((DIM*2)⍴(2 ⍷ sum)) / ⍳DIM*2 
  manh←{(⌊⍵÷DIM)+(DIM|⍵)} results
  result ← 1↑1↓manh[⍋manh]
∇

(a b) ← 'U7,R6,D4,L4' 'R8,U5,L5,D3'
⍝(a b) ← 'R75,D30,R83,U83,L12,D49,R71,U7,L72' 'U62,R66,U55,R34,D71,R55,D58,R83'
'Part 1: ', solve a b

⍝{⊢/⍵}¨+\s1parse a

)OFF
