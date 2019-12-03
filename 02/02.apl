#!/usr/local/bin/apl -s

⎕IO←0 ⍝ index from 0

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

∇result ← vn with program
  program[1]←vn[0]
  program[2]←vn[1]
  result←(exec program)[0]
∇

'Part 1 answer:', 12 2 with program

target←19690720
∇result ← nvt part2 program
result←⍬
 r←(2↑nvt) with program
 →(end found)[nvt[2]=r]
 end:→0
 found: 'Part 2 answer:', nvt[1] + 100 × nvt[0]
∇

⊣(⍳100)∘.{⍺ ⍵ target part2 program}(⍳100)

)OFF
