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
  (ip params program memory robot hull) ← args
  program[program[ip + 3]] ← FN/ {GET_PARAMETER program memory ip ⍵ params}¨ 0 1
  result ← (ip + 4) program  memory robot hull
∇

⍝ MUL←{×BINOP ⍵}
∇ result ← MUL x; ip; i1; i2; o; program; params; in; out;p1;p2;ra
  (ip params program  memory robot hull) ← x
  (program memory p1)←GET_PARAMETER program memory ip 0 params
  (program memory p2)←GET_PARAMETER program memory ip 1 params
  ra←GET_ADDRESS program memory ip 2 params
  (program memory)←STA program memory ra (p1×p2)
  result ← (ip + 4) program  memory robot hull
∇

∇ result ← ADD x; ip; i1; i2; o; program; params; in; out;p1;p2;ra
  (ip params program  memory robot hull) ← x
  (program memory p1)←GET_PARAMETER program memory ip 0 params
  (program memory p2)←GET_PARAMETER program memory ip 1 params
  ra←GET_ADDRESS program memory ip 2 params
  (program memory)←STA program memory ra (p1+p2)
  result ← (ip + 4) program  memory robot hull
∇

∇ result ← INPUT x; ip; i1; o; program; params; in; out; vtw
  (ip params program memory robot hull) ← x

  i1 ← GET_ADDRESS program memory ip 0 params
  (hull vtw) ← READ_HULL hull (⊃(robot[0])) ⍝ value to write is the color of hull on robot's position
⍝'INPUT read value' vtw
  (program memory)←STA program memory i1 vtw 
  ip ← ip + 2
  result ← ip program memory robot hull
∇

∇ result ← OUTPUT x; ip; i1; i2; o; program; params; in; out; oval
  (ip params program memory robot hull) ← x
  (program memory oval) ← GET_PARAMETER program memory ip 0 params
⍝'OUTPUT, robot:'
⍝DISPLAY robot
⍝'OUTPUT, value:'oval
⍝'OUTPUT, hull:'
⍝DISPLAY hull

→(PAINTING MOVING)[robot[2]]
PAINTING:
  hull ← WRITE_HULL hull (⊃(robot[0])) oval ⍝ paint the hull
⍝'OUTPUT, hull painted:'
⍝DISPLAY hull
  robot[2] ← 1 ⍝ change to move mode
  →END

MOVING:
robot[1]←4|(or←robot[1]) + (¯1 1)[oval] ⍝ -1 counter clockwise, 1 clockwise
⍝'OUTPUT direction change - by'oval'changed to'robot[1]
robot[0] ← robot[0] + ((0 1) (1 0) (0 ¯1) (¯1 0))[robot[1]]
robot[2] ← 0 ⍝ change to paint mode
⍝'OUTPUT, robot moved:'robot


END:  
  result ← (ip + 2) program memory robot hull
∇

∇ result ← JT x; ip; program; params; condition; target; in; out
  (ip params program memory robot hull) ← x
  (program memory condition)←GET_PARAMETER program memory ip 0 params
  (program memory target)←GET_PARAMETER program memory ip 1 params
  →(SKIP JUMP)[1⌊condition]
  JUMP:result ← target program memory robot hull
  →0
  SKIP:result ← (ip + 3) program memory robot hull
∇

∇ result ← JF x; ip; program; params; condition; target; in; out
  (ip params program memory robot hull) ← x
  (program memory condition)←GET_PARAMETER program memory ip 0 params
  (program memory target)←GET_PARAMETER program memory ip 1 params
  →(SKIP JUMP)[~1⌊condition]
  JUMP:result ← target program memory robot hull
  →0
  SKIP:result ← (ip + 3) program memory robot hull
∇

∇ result ← LT x; ip; program; params; condition; target; in; out;p1;p2;ra
  (ip params program memory robot hull) ← x
  (program memory p1)←GET_PARAMETER program memory ip 0 params
  (program memory p2)←GET_PARAMETER program memory ip 1 params
  ra←GET_ADDRESS program memory ip 2 params
  (program memory)←STA program memory ra  (p1<p2)
  result ← (ip + 4) program memory robot hull
∇

∇ result ← EQ x; ip; program; params; condition; target; in; out;p1;p2;ra
  (ip params program memory robot hull) ← x
  (program memory p1)←GET_PARAMETER program memory ip 0 params
  (program memory p2)←GET_PARAMETER program memory ip 1 params
  ra←GET_ADDRESS program memory ip 2 params
  (program memory)←STA program memory ra (p1=p2)
  result ← (ip + 4) program memory robot hull
∇

∇ result ← HALT args
  (ip params program memory robot hull) ← args
  result ← ¯1 program memory robot hull
∇

∇ result ← ARB args
  (ip params program memory robot hull) ← args
  (program memory p1)←GET_PARAMETER program memory ip 0 params
  memory[0]←memory[0]+p1
  result ← (ip + 2) program memory robot hull
∇

∇ return ← STEP args; ip; program; opcode; fn_name; fn; operation; params
  (ip program memory robot hull) ← args
  opcode ← ¯2↑'0',⍕program[ip] ⍝ add leading 0 to be sure opcode is at least 2 chars
  fn_name ← {⍵[0;]}⊃(('01' '02' '03' '04' '05' '06' '07' '08' '09' '99') ≡¨ ⊂opcode) / 'ADD' 'MUL' 'INPUT' 'OUTPUT' 'JT' 'JF' 'LT' 'EQ' 'ARB' 'HALT' ⍝ translate opcode to function 
  params←¯2↓'00',⍕program[ip]
  ⍎'fn←{',fn_name,' ⍵}'

  ⍎(~DEBUG)/'→NOT_DEBUG'
  memory_content←2↓memory
  ⍎(0<≢memory_content)/'memory_content←memory_content[⍋0⊃¨memory_content]'
  ip fn_name params (4↑ip↓program) '|' (↑memory) memory_content
  'robot:'
  DISPLAY robot
  'hull:'
  DISPLAY hull
  NOT_DEBUG:

  return←fn ip params program memory robot hull
∇

∇ hull ← RUN args; program; input; ip; in; out; tick
  (program memory) ← args
  ip ← 0
  out ← ⍬
  tick←0
  n ← 0
  robot ← (0 0) 0 0 ⍝ starting at 0, 0, heading north (0), painting (0)
  hull ← ,⊂((0 0) 1) ⍝ part 1: black, part 2: white
  LOOP:

tick
⍎(~DEBUG)/'→SK'
  (,'-')[80/0]
tick
⍎(n>0)/'n←n-1◊→SK'
'Insert cmd'
  n←⍞
  ⍎(0<≢n)/'n←⍎n◊→SK'
  n←0
SK:
  (ip program memory robot hull) ← STEP ip program memory robot hull
  tick←tick+1
  →(LOOP 0)[ip < 0]
∇

∇ return ← READ_HULL args; hull; value
  (hull position) ← args

index ← (⊂position)⍷0⊃¨hull
⍎(∨/index)/'index←index/⍳⍴hull◊→FOUND'

⍝ not found -> return 0
return ← hull 0
→0

hull←hull, ⊂(position 0)
index ← ¯1+⍴hull
FOUND:
  value ← index 1⊃hull
  return ← hull value 
∇

∇ hull ← WRITE_HULL args; hull; value
  (hull position value) ← args

index ← (⊂position)⍷0⊃¨hull

⍎(∨/index)/'index←index/⍳⍴hull◊→FOUND'
hull←hull, ⊂(position 0)
index ← ¯1+⍴hull
FOUND:
  (index 1⊃hull) ← value
∇

hull ← RUN program (0 (¯1 0))
xs ← 0⊃¨0⊃¨hull
ys ← 1⊃¨0⊃¨hull
(miX maX) ← (⌊/xs) (⌈/xs)
(miY maY) ← (⌊/ys) (⌈/ys)
pic ← (1+(|maY-miY) (|maX-miX))⍴0

⊢{pic[-(0 1⊃⍵);0 0⊃⍵]←⍵[1]}¨hull
' #'[pic]
⍴hull ⍝ part 1 - number of painted tiles

'Done.'
)OFF
