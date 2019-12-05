#!/usr/local/bin/apl -s

⎕IO←0 ⍝ index from 0
DISPLAY ← {4⎕CR⍵}
GET_LINES ← {⎕FIO[49]⍵}

halt ← 0
filename ← {⍵[0;]}⊃¯1↑⎕ARG

'Loading program ', filename

raw←{⍵[0;]}⊃GET_LINES filename ⍝ load the whole file
raw[('-'⍷raw)/⍳⍴raw]←'¯' ⍝ substitute - for ¯ in order for APL to interpret the negative values correctly
program ← ⍎raw
'Program:' program

∇ result ← GET_PARAMETER x; program; ip; i; params;value
  (program ip i params) ← x

  value←program[1+ip+i]

  params ← '000000',⍕params
  params ← ⌽params

  →(DEREF IMM)[⍎params[i]]
  DEREF:value←program[value]
  IMM:result←value
∇

∇ newip ← MUL x; ip; i1; i2; o; program; params
  (ip params program) ← x
  program[program[ip + 3]] ← ×/ {GET_PARAMETER program ip ⍵ params}¨ 0 1
  newip ← (ip + 4) program
∇

∇ newip ← ADD x; ip; i1; i2; o; program; params
  (ip params program) ← x
  program[program[ip + 3]] ← +/ {GET_PARAMETER program ip ⍵ params}¨ 0 1
  newip ← (ip + 4) program
∇

∇ newip ← INPUT x; ip; i1; o; program; params
  (ip params program) ← x
  i1 ← program[ip+1]
  'INPUT writing 1 to ', i1
  program[i1] ← 1 ⍝ INPUT
  newip ← (ip + 2) program
∇

∇ newip ← OUTPUT x; ip; i1; i2; o; program; params
  (ip params program) ← x
  'OUTPUT'
  DISPLAY program[program[ip+1]]
  newip ← (ip + 2) program
∇

∇ omit ← HALT p
  (omit halt) ← 0 1
∇

∇ newip ← STEP p; ip; program; opcode; fn; operation; params
  (ip program) ← p
  opcode ← ¯2↑'0',⍕program[ip] ⍝ add leading 0 to be sure opcode is at least 2 chars
  fn ← {⍵[0;]}⊃(('01' '02' '03' '04' '99') ≡¨ ⊂opcode) / 'ADD' 'MUL' 'INPUT' 'OUTPUT' 'HALT' ⍝ translate opcode to function
  params←¯2↓'00',⍕program[ip]
  newip ← ⍎ fn,' ',⍕ip  params  '(' program ')'
∇

∇ RUN program; ip
  ip ← 0
  LOOP:
  (ip program) ← STEP ip program
  →(LOOP 0)[halt]
∇

RUN program
'Done.'

)OFF
