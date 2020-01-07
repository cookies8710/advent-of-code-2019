#!/usr/local/bin/apl -s

⎕IO←0 ⍝ index from 0
DISPLAY ← {4⎕CR⍵}
GET_LINES ← {⎕FIO[49]⍵}

DEBUG ← 1 ⍝ in debug mode, tick, IP, next instruction and memory content is shown; input is either just ENTER (1 step) or a number of steps to execute

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
  (ip params program memory in out) ← args
  program[program[ip + 3]] ← FN/ {GET_PARAMETER program memory ip ⍵ params}¨ 0 1
  result ← (ip + 4) program  memory in out
∇

⍝ MUL←{×BINOP ⍵}
∇ result ← MUL x; ip; i1; i2; o; program; params; in; out;p1;p2;ra
  (ip params program  memory in out) ← x
  (program memory p1)←GET_PARAMETER program memory ip 0 params
  (program memory p2)←GET_PARAMETER program memory ip 1 params
  ra←GET_ADDRESS program memory ip 2 params
  (program memory)←STA program memory ra (p1×p2)
  result ← (ip + 4) program  memory in out
∇

∇ result ← ADD x; ip; i1; i2; o; program; params; in; out;p1;p2;ra
  (ip params program  memory in out) ← x
  (program memory p1)←GET_PARAMETER program memory ip 0 params
  (program memory p2)←GET_PARAMETER program memory ip 1 params
  ra←GET_ADDRESS program memory ip 2 params
  (program memory)←STA program memory ra (p1+p2)
  result ← (ip + 4) program  memory in out
∇

∇ result ← INPUT x; ip; i1; o; program; params; in; out; vtw
  (ip params program memory in out) ← x
  ⍎((↑in)≥⍴1⊃in)/'→END' ⍝ block if not enough input values; this is important for part 2
  i1 ← GET_ADDRESS program memory ip 0 params
  vtw ← 1 (↑in)⊃in  
  in[0] ←1+↑in 
  (program memory)←STA program memory i1 vtw 
  ip ← ip + 2
END:
  result ← ip program memory in out
∇

∇ result ← OUTPUT x; ip; i1; i2; o; program; params; in; out; oval
  (ip params program memory in out) ← x
  (program memory oval) ← GET_PARAMETER program memory ip 0 params
  result ← (ip + 2) program memory in (out, oval)
∇

∇ result ← JT x; ip; program; params; condition; target; in; out
  (ip params program memory in out) ← x
  (program memory condition)←GET_PARAMETER program memory ip 0 params
  (program memory target)←GET_PARAMETER program memory ip 1 params
  →(SKIP JUMP)[1⌊condition]
  JUMP:result ← target program memory in out
  →0
  SKIP:result ← (ip + 3) program memory in out
∇

∇ result ← JF x; ip; program; params; condition; target; in; out
  (ip params program memory in out) ← x
  (program memory condition)←GET_PARAMETER program memory ip 0 params
  (program memory target)←GET_PARAMETER program memory ip 1 params
  →(SKIP JUMP)[~1⌊condition]
  JUMP:result ← target program memory in out
  →0
  SKIP:result ← (ip + 3) program memory in out
∇

∇ result ← LT x; ip; program; params; condition; target; in; out;p1;p2;ra
  (ip params program memory in out) ← x
  (program memory p1)←GET_PARAMETER program memory ip 0 params
  (program memory p2)←GET_PARAMETER program memory ip 1 params
  ra←GET_ADDRESS program memory ip 2 params
  (program memory)←STA program memory ra  (p1<p2)
  result ← (ip + 4) program memory in out
∇

∇ result ← EQ x; ip; program; params; condition; target; in; out;p1;p2;ra
  (ip params program memory in out) ← x
  (program memory p1)←GET_PARAMETER program memory ip 0 params
  (program memory p2)←GET_PARAMETER program memory ip 1 params
  ra←GET_ADDRESS program memory ip 2 params
  (program memory)←STA program memory ra (p1=p2)
  result ← (ip + 4) program memory in out
∇

∇ result ← HALT args
  (ip params program memory in out) ← args
  result ← ¯1 program memory in out
∇

∇ result ← ARB args
  (ip params program memory in out) ← args
  (program memory p1)←GET_PARAMETER program memory ip 0 params
  memory[0]←memory[0]+p1
  result ← (ip + 2) program memory in out
∇

∇ return ← STEP args; ip; program; opcode; fn_name; fn; operation; params
  (ip program memory in out) ← args
  opcode ← ¯2↑'0',⍕program[ip] ⍝ add leading 0 to be sure opcode is at least 2 chars
  fn_name ← {⍵[0;]}⊃(('01' '02' '03' '04' '05' '06' '07' '08' '09' '99') ≡¨ ⊂opcode) / 'ADD' 'MUL' 'INPUT' 'OUTPUT' 'JT' 'JF' 'LT' 'EQ' 'ARB' 'HALT' ⍝ translate opcode to function 
  params←¯2↓'00',⍕program[ip]
  ⍎'fn←{',fn_name,' ⍵}'


  ⍎(~DEBUG)/'→NOT_DEBUG'
  memory_content←2↓memory
  ⍎(0<≢memory_content)/'memory_content←memory_content[⍋0⊃¨memory_content]'
  ip fn_name params (4↑ip↓program) '|' (↑memory) memory_content
  NOT_DEBUG:

  return←fn ip params program memory in out
∇

∇ out ← RUN args; program; input; ip; in; out; tick
  (program memory input) ← args
  ip ← 0
  out ← ⍬
  tick←0
  n ← 0
  LOOP:

⍎(~DEBUG)/'→SK'
tick
⍝⍎(ip=940)/'n←0'
⍎(n>0)/'n←n-1◊→SK'
'Insert cmd'
  n←⍞
  ⍎(0<≢n)/'n←⍎n◊→SK'
  n←0
SK:
  (ip program memory in out) ← STEP ip program memory (0 (,input)) out
  tick←tick+1
  →(LOOP 0)[ip < 0]
∇

RUN program (0 (¯1 0)) 1
RUN program (0 (¯1 0)) 2

'Done.'
)OFF
