#!/usr/local/bin/apl -s

⎕IO←0 ⍝ index from 0
DISPLAY ← {4⎕CR⍵}
GET_LINES ← {⎕FIO[49]⍵}

⍝ global variables 
filename ← {⍵[0;]}⊃¯1↑⎕ARG

'Loading program ', filename

raw←{⍵[0;]}⊃GET_LINES filename ⍝ load the whole file
raw[('-'⍷raw)/⍳⍴raw]←'¯' ⍝ substitute - for ¯ in order for APL to interpret the negative values correctly
program ← ⍎raw
'Program:' program

∇ return ← PF arg
⍝→(C1 ZERO)[arg≡⍬]
  →(C1 ZERO)[0=⍴arg]
  ZERO:return←'⍬'
  →0
  C1:→(MULTI ONE)[⍬≡⍴arg]
  ⍝ONE:return←⍕arg
  ONE: return←'(,'arg')'
  →0
  MULTI:
  return←'('arg')'
∇

∇ return ← ACU arg; a;b
  (a b) ← arg

  (a b) ← (1↓a) (b,1↑a)

  return ← a b
∇

∇ result ← GET_PARAMETER x; program; ip; i; params;value
  (program ip i params) ← x

  value←program[1+ip+i]

  params ← '000000',⍕params
  params ← ⌽params

  →(DEREF IMM)[⍎params[i]]
  DEREF:value←program[value]
  IMM:result←value
∇

∇ result ← MUL x; ip; i1; i2; o; program; params; in; out
  (ip params program in out) ← x
  program[program[ip + 3]] ← ×/ {GET_PARAMETER program ip ⍵ params}¨ 0 1
  result ← (ip + 4) program in out
∇

∇ result ← ADD x; ip; i1; i2; o; program; params; in; out
  (ip params program in out) ← x
  program[program[ip + 3]] ← +/ {GET_PARAMETER program ip ⍵ params}¨ 0 1
  result ← (ip + 4) program in out
∇

∇ result ← INPUT x; ip; i1; o; program; params; in; out; vtw
  (ip params program in out) ← x
  i1 ← program[ip+1]
  vtw ← 1↑in 
  in ← 1↓in
  program[i1] ← vtw 
  result ← (ip + 2) program in out
∇

∇ result ← OUTPUT x; ip; i1; i2; o; program; params; in; out; oval
  (ip params program in out) ← x
  oval ← GET_PARAMETER program ip 0 params
  DISPLAY oval
  result ← (ip + 2) program in (out, oval)
∇

∇ result ← JT x; ip; program; params; condition; target; in; out
  (ip params program in out) ← x
  (condition target) ← {GET_PARAMETER program ip ⍵ params}¨ 0 1
  →(SKIP JUMP)[1⌊condition]
  JUMP:result ← target program in out
  →0
  SKIP:result ← (ip + 3) program in out
∇

∇ result ← JF x; ip; program; params; condition; target; in; out
  (ip params program in out) ← x
  (condition target) ← {GET_PARAMETER program ip ⍵ params}¨ 0 1
  →(SKIP JUMP)[~1⌊condition]
  JUMP:result ← target program in out
  →0
  SKIP:result ← (ip + 3) program in out
∇

∇ result ← LT x; ip; program; params; condition; target; in; out
  (ip params program in out) ← x
  program[program[ip + 3]] ← </ {GET_PARAMETER program ip ⍵ params}¨ 0 1
  result ← (ip + 4) program in out
∇

∇ result ← EQ x; ip; program; params; condition; target; in; out
  (ip params program in out) ← x
  program[program[ip + 3]] ← =/ {GET_PARAMETER program ip ⍵ params}¨ 0 1
  result ← (ip + 4) program in out
∇

∇ result ← HALT args
  (ip params program in out) ← args
  result ← ¯1 program in out
∇

∇ newip ← STEP args; ip; program; opcode; fn; operation; params
  (ip program in out) ← args
  opcode ← ¯2↑'0',⍕program[ip] ⍝ add leading 0 to be sure opcode is at least 2 chars
  fn ← {⍵[0;]}⊃(('01' '02' '03' '04' '05' '06' '07' '08' '99') ≡¨ ⊂opcode) / 'ADD' 'MUL' 'INPUT' 'OUTPUT' 'JT' 'JF' 'LT' 'EQ' 'HALT' ⍝ translate opcode to function
  params←¯2↓'00',⍕program[ip]
  str←⍕fn ip params '('program')' ' ' (PF in) ' ' (PF out)
'STEP' str  
  newip ← ⍎str
∇

∇ out ← RUN args; program; input; phase; ip; halt; in; out
  (program input phase) ← args
  ip ← 0
  halt ← 0
  (in out) ← (input phase) ⍬ 
  LOOP:
  (ip program in out) ← STEP ip program in out
  halt ← ip < 0
  →(LOOP 0)[halt]
∇

'P1:'

∇ return ← AMP arg; in; i
  (program phases) ← arg
  out ← ⍬
  i ← 0
  L: out ← RUN program phases[i] out
  i←i+1
  ⍎(i<5)/'→L'
  return ← out
∇

AMP program (0 1 2 3 4)


⍝'IO Test program'
⍝RUN (3 9 4 9 3 9 4 9 99 0) 7 6 ⍝ output should be 7 6

∇ r FN args
 'FN called, args:'
 DISPLAY args
 r←0
∇

⍝FN (1 2 3) 'koko'
⍝a ← 1 0
⍝b ← 0
⍝str←'FN ('a') (,'b')'
⍝
⍝DISPLAY str
⍝DISPLAY 'FN ( 1 0 )'
⍝⍎⍕ str

⍝ accu
⍝ pos form 
⍝⍎⍕PF ⍬
⍝⍎⍕PF 0
⍝⍎⍕PF 1
⍝⍎⍕PF 1 2 3

⍝(a b) ← (1 2 3) ⍬

∇ result ACU2 arg; a; b; str
  (a b) ← arg
  AL:
  str ← ⍕ 'ACU' (PF a)  (PF b)
  DISPLAY str
  (a b) ← ⍎str
  'a:'
  DISPLAY a
  'b:'
  DISPLAY b
  →(AL 0)[0=⍴a]
∇

⍝ACU2 a b

∇ result PERM vec
'PERM'
DISPLAY vec
  result ← vec
  ⍎(1=⍴vec)/'→0'
  ⍎(⍬≡⍴vec)/'→0'

'⍴'
DISPLAY ⍴vec
DISPLAY vec[0]
DISPLAY (1↓vec)
  result ← vec[0] {(⍺,⍵)}¨ PERM (1↓vec)
∇

PERM 1 2
'Done.'
)OFF
