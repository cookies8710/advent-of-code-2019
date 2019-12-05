#!/usr/local/bin/apl -s

⎕IO←0 ⍝ index from 0
DISPLAY ← {4⎕CR⍵}
GET_LINES ← {⎕FIO[49]⍵}

filename ← {⍵[0;]}⊃¯1↑⎕ARG
'Loading program ', filename
xxx←{⍵[0;]}⊃GET_LINES filename
xi←'-'⍷xxx
xxx[xi/⍳⍴xi]←'¯'
program ← ⍎xxx
'Program:' program
xx←program {2 1⍴(⍵ ⍺)}¨ ⍳⍴program


halt ← 0

∇ newip ← MUL x; ip; i1; i2; o; program; params
  (ip params program) ← x


  params ← '000000',⍕params
  params ← ⌽params

  i1 ← program[ip+1]
  i2 ← program[ip+2]

  →(M1 I1)[⍎params[0]]
  M1:i1←program[i1]
  I1:
  
  →(M2 I2)[⍎params[1]]
  M2:i2←program[i2]
  I2:

  program[program[ip + 3]] ← i1 × i2

  newip ← (ip + 4) program
∇

∇ newip ← ADD x; ip; i1; i2; o; program; params
  (ip params program) ← x

  params ← '000000',⍕params
  params ← ⌽params

  i1 ← program[ip+1]
  i2 ← program[ip+2]

  →(M1 I1)[⍎params[0]]
  M1:i1←program[i1]
  I1:
  
  →(M2 I2)[⍎params[1]]
  M2:i2←program[i2]
  I2:

  program[program[ip + 3]] ← i1 + i2

  newip ← (ip + 4) program
∇

∇ newip ← INPUT x; ip; i1; i2; o; program; params
  (ip params program) ← x

  params ← ⌽⍕params

  i1 ← program[ip+1]
  'INPUT writing 1 to ', i1
  program[i1] ← 1 ⍝ INPUT

  newip ← (ip + 2) program
∇

∇ newip ← OUTPUT x; ip; i1; i2; o; program; params
  (ip params program) ← x

  params ← ⌽⍕params

  i1 ← program[ip+1]
  
  'OUTPUT'
  DISPLAY program[i1]

  newip ← (ip + 2) program
∇

∇ omit ← HALT p
  (omit halt) ← 0 1
∇

∇ newip ← process p; ip; program; opcode; fn; operation; params
  (ip program) ← p

  ⍝operation ←

  opcode ← ¯2↑'0',⍕program[ip] ⍝ add leading 0 to be sure opcode is at least 2 chars
  fn ← {⍵[0;]}⊃(('01' '02' '03' '04' '99') ≡¨ ⊂opcode) / 'ADD' 'MUL' 'INPUT' 'OUTPUT' 'HALT'

  params←¯2↓'00000',⍕program[ip]

  newip ← ⍎ fn,' ',⍕ip  params  '(' program ')'
∇

∇ RUN program; ip
  ip ← 0
  LOOP:
  (ip program) ← process ip program
  →(LOOP 0)[halt]
∇

RUN program
'Done.'

)OFF
