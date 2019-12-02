#!/usr/local/bin/apl -s

⎕IO←0 ⍝ index from 0

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
  line ← ⎕FIO[8] f
  →(CONT END)[eof f]
  CONT: result ← result, line
  →READ
  END:
  null ← ⎕FIO[4] f ⍝ fclose ⍝ don't print fclose's result
∇

∇result←d sf a
  result←⍬
  →(nonempty empty)[a≡⍬]
  empty: →0
  nonempty:
  →(cont end)[a[0]=d]
  end:→0
  cont:result←a[0],d sf 1↓a
∇

∇ret←d find a
 ret←-1
 i←0
 →(end c1)[d∊a]
 c1:
 →(cont succ)[a[i]=d]
 cont:
 i←i+1
 →c1
 end:→0 
 succ:
 ret←i
 →0
∇

⍝ splits a by d, e.g. ',' split '1,3' -> 1 3
∇ result ← d split a;next;x;y
  result ← ⍬
  next←d find a
  →(cont end)[next=¯1]
  end:
  result←10⊥a-48
  →0
  cont:
  x←10⊥(next↑a) - 48
  result←x, d split (next+1)↓a 
∇

⍝ split by , (44), drop the last char (\n)
program ← 44 split ¯1↓readall 'input'

'program: ', program

∇result←i step vec
 opindex←i × 4
 opcode←vec[opindex]
 →(cont end)[opcode=99]
 end:
 result←vec
 →0
 cont:→(add mul)[opcode-1]
 add:
 vec[vec[opindex+3]]←vec[vec[opindex+1]]+vec[vec[opindex+2]]
 result←vec
 →0
 mul:
 vec[vec[opindex+3]]←vec[vec[opindex+1]]×vec[vec[opindex+2]]
 result←vec
 →0
∇

∇result←exec vec
 i←0
loop:
 opindex←i×4
 opcode←vec[opindex]
 vec←i step vec
 i←i+1
 →(loop end)[opcode=99]
end:result←vec
∇

program[1]←12
program[2]←2
(exec program)[0]

)OFF
