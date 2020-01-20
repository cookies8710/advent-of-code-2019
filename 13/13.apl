#!/usr/local/bin/apl -s

⎕IO←0 ⍝ index from 0
DISPLAY ← {4⎕CR⍵}
GET_LINES ← {⎕FIO[49]⍵}

DEBUG ← 0 ⍝ in debug mode, tick, IP, next instruction and memory content is shown; input is either just ENTER (1 step) or a number of steps to execute

⍝ global variables 
filename ← {⍵[0;]}⊃¯1↑⎕ARG

'Loading program ', filename

raw←{⍵[0;]}⊃GET_LINES filename ⍝ load the whole file
raw[('-'⍷raw)/⍳⍴raw]←'¯' ⍝ substitute - for ¯ in order for APL to interpret the negative values correctly
program ← ⍎raw
'Program:' program

∇ result ← LDA args;program;memory;addr;place;val
  (program memory addr) ← args
  ⍎(addr < ⍴program)/'result←program memory program[addr]◊→0'
  place←addr=0⊃¨1↓memory
  ⍎(∨/place)/'→EX'

  memory←memory, (⊂addr 0)
  place←addr=0⊃¨1↓memory
EX:
val←(1+place/⍳¯1+⍴memory) 1⊃memory
result←program memory val
∇

∇ result ← STA args;program;memory;addr;val;place
  (program memory addr val) ← args
  ⍎(addr < ⍴program)/'program[addr]←val◊result←program memory◊→0'
  place←addr=0⊃¨1↓memory
  ⍎(∨/place)/'→EX'

  memory←memory, (⊂addr 0)
  place←addr=0⊃¨1↓memory
EX:
((1+place/⍳¯1+⍴memory) 1⊃memory)←val
 result ← program memory
∇

∇ result ← GET_ADDRESS x; program; ip; i; params;value;memory
  (program memory ip i params) ← x

  value←program[1+ip+i]

  params ← '000000',⍕params
  params ← ⌽params

  →(DEREF IMM REL)[⍎params[i]]
  REL:value←value+↑memory ⍝ offset value by relative base
  DEREF:result←value
  →0
  IMM:error
∇ 

∇ result ← GET_PARAMETER x; program; ip; i; params;value;memory
  (program memory ip i params) ← x

  value←program[1+ip+i]

  params ← '000000',⍕params
  params ← ⌽params

  →(DEREF IMM REL)[⍎params[i]]
  REL:value←value+↑memory ⍝ offset value by relative base
  DEREF:(program memory value)←LDA program memory value
  IMM:result←program memory value
∇ 

∇ result ← (FN BINOP) args
  (ip params program memory screen) ← args
  program[program[ip + 3]] ← FN/ {GET_PARAMETER program memory ip ⍵ params}¨ 0 1
  result ← (ip + 4) program  memory screen
∇

⍝ MUL←{×BINOP ⍵}
∇ result ← MUL x; ip; i1; i2; o; program; params; in; out;p1;p2;ra
  (ip params program  memory screen) ← x
  (program memory p1)←GET_PARAMETER program memory ip 0 params
  (program memory p2)←GET_PARAMETER program memory ip 1 params
  ra←GET_ADDRESS program memory ip 2 params
  (program memory)←STA program memory ra (p1×p2)
  result ← (ip + 4) program  memory screen
∇

∇ result ← ADD x; ip; i1; i2; o; program; params; in; out;p1;p2;ra
  (ip params program  memory screen) ← x
  (program memory p1)←GET_PARAMETER program memory ip 0 params
  (program memory p2)←GET_PARAMETER program memory ip 1 params
  ra←GET_ADDRESS program memory ip 2 params
  (program memory)←STA program memory ra (p1+p2)
  result ← (ip + 4) program  memory screen
∇

∇ result ← INPUT x; ip; i1; o; program; params; in; out; vtw
  (ip params program memory screen) ← x

(a b c)←screen
  i1 ← GET_ADDRESS program memory ip 0 params

total←20×38
ball←38|(total⍴4⍷c)/⍳total
paddle←38|(total⍴3⍷c)/⍳total
vtw ←×ball-paddle ⍝ move the paddle towards the ball

  (program memory)←STA program memory i1 vtw 
  ip ← ip + 2
  result ← ip program memory screen
∇

blocks ←0
(xs ys)←0
∇ result ← OUTPUT x; ip; i1; i2; o; program; params; in; out; oval
  (ip params program memory screen) ← x
  (m score data)←screen
  (program memory oval) ← GET_PARAMETER program memory ip 0 params

→(X Y TILE)[m]
X:xs←oval
→END
Y:ys←oval
→END
TILE:
⍎(oval=2)/'blocks←blocks+1'
⍎(∧/xs ys = ¯1 0)/'score←oval◊→END'
data[ys;xs]←oval
→END

END:
m ← 3|m + 1 ⍝ rotate output mode

  result ← (ip + 2) program memory (m score data)
∇

∇ result ← JT x; ip; program; params; condition; target; in; out
  (ip params program memory screen) ← x
  (program memory condition)←GET_PARAMETER program memory ip 0 params
  (program memory target)←GET_PARAMETER program memory ip 1 params
  →(SKIP JUMP)[1⌊condition]
  JUMP:result ← target program memory screen
  →0
  SKIP:result ← (ip + 3) program memory screen
∇

∇ result ← JF x; ip; program; params; condition; target; in; out
  (ip params program memory screen) ← x
  (program memory condition)←GET_PARAMETER program memory ip 0 params
  (program memory target)←GET_PARAMETER program memory ip 1 params
  →(SKIP JUMP)[~1⌊condition]
  JUMP:result ← target program memory screen
  →0
  SKIP:result ← (ip + 3) program memory screen
∇

∇ result ← LT x; ip; program; params; condition; target; in; out;p1;p2;ra
  (ip params program memory screen) ← x
  (program memory p1)←GET_PARAMETER program memory ip 0 params
  (program memory p2)←GET_PARAMETER program memory ip 1 params
  ra←GET_ADDRESS program memory ip 2 params
  (program memory)←STA program memory ra  (p1<p2)
  result ← (ip + 4) program memory screen
∇

∇ result ← EQ x; ip; program; params; condition; target; in; out;p1;p2;ra
  (ip params program memory screen) ← x
  (program memory p1)←GET_PARAMETER program memory ip 0 params
  (program memory p2)←GET_PARAMETER program memory ip 1 params
  ra←GET_ADDRESS program memory ip 2 params
  (program memory)←STA program memory ra (p1=p2)
  result ← (ip + 4) program memory screen
∇

∇ result ← HALT args
  (ip params program memory screen) ← args
  result ← ¯1 program memory screen
∇

∇ result ← ARB args
  (ip params program memory screen) ← args
  (program memory p1)←GET_PARAMETER program memory ip 0 params
  memory[0]←memory[0]+p1
  result ← (ip + 2) program memory screen
∇

∇ return ← STEP args; ip; program; opcode; fn_name; fn; operation; params
  (ip program memory screen) ← args
  opcode ← ¯2↑'0',⍕program[ip] ⍝ add leading 0 to be sure opcode is at least 2 chars
  fn_name ← {⍵[0;]}⊃(('01' '02' '03' '04' '05' '06' '07' '08' '09' '99') ≡¨ ⊂opcode) / 'ADD' 'MUL' 'INPUT' 'OUTPUT' 'JT' 'JF' 'LT' 'EQ' 'ARB' 'HALT' ⍝ translate opcode to function 
  params←¯2↓'00',⍕program[ip]
  ⍎'fn←{',fn_name,' ⍵}'
  return←fn ip params program memory screen
∇

∇ screen ← RUN args; program; input; ip; in; out; tick
  (program memory) ← args
  ip ← 0
  out ← ⍬
  tick←0
  n ← 0
  ⍝robot ← (0 0) 0 0 ⍝ starting at 0, 0, heading north (0), painting (0)
  ⍝hull ← ,⊂((0 0) 1) ⍝ part 1: black, part 2: white
  screen ← 0 0 (20 38⍴0)
  LOOP:
  (ip program memory screen) ← STEP ip program memory screen
  'Score:'(1⊃screen)
  ' #=-∘'[2⊃screen]
  tick←tick+1
  →(LOOP 0)[ip < 0]
∇

program[0]←2
(m screen) ← RUN program (0 (¯1 0))
⍝blocks ⍝ Part 1 - 280

'Done.'
)OFF
