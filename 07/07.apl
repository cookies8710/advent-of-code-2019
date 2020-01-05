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
  ⍎((↑in)≥⍴1⊃in)/'→END' ⍝ block if not enough input values; this is important for part 2
  i1 ← program[ip+1]
  vtw ← 1 (↑in)⊃in  
  in[0] ←1+↑in 
  program[i1] ← vtw 
  ip ← ip + 2
END:
  result ← ip program in out
∇

∇ result ← OUTPUT x; ip; i1; i2; o; program; params; in; out; oval
  (ip params program in out) ← x
  oval ← GET_PARAMETER program ip 0 params
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

∇ return ← STEP args; ip; program; opcode; fn_name; fn; operation; params
  (ip program in out) ← args
  opcode ← ¯2↑'0',⍕program[ip] ⍝ add leading 0 to be sure opcode is at least 2 chars
  fn_name ← {⍵[0;]}⊃(('01' '02' '03' '04' '05' '06' '07' '08' '99') ≡¨ ⊂opcode) / 'ADD' 'MUL' 'INPUT' 'OUTPUT' 'JT' 'JF' 'LT' 'EQ' 'HALT' ⍝ translate opcode to function 
  params←¯2↓'00',⍕program[ip]
  ⍎'fn←{',fn_name,' ⍵}'
  return←fn ip params program in out
∇

∇ out ← RUN args; program; input; phase; ip; in; out;tick
  (program input phase) ← args
  ip ← 0
  in ← 0 (phase,input)  
  out ← ⍬
  LOOP:
  (ip program in out) ← STEP ip program in out
  →(LOOP 0)[ip < 0]
∇

∇ return ← AMP arg; in; out; phases; program
  (program phases) ← arg
  out ← 0
  ⊣{out←RUN program out ⍵}¨phases
  return ← out
∇

∇ return ← AMP2 arg; in; i;out; phases; program
  ⍝ TODO refactor this
  (program phases) ← arg
  A←0 program (0 (phases[0] 0)) ⍬
  B←0 program (0 (,phases[1])) ⍬
  C←0 program (0 (,phases[2])) ⍬
  D←0 program (0 (,phases[3])) ⍬
  E←0 program (0 (,phases[4])) ⍬

return←⍬
phases
TA:
  ips←A[0]B[0]C[0]D[0]D[0]E[0]
  ⍎(∧/0>ips)/'→END'⍝ if all programs halted, end

  ⍎(0>↑A)/'→TB'
  result←STEP A
  A[0 1 2]←result[0 1 2]
  (2 1⊃B)←(2 1⊃B),⊃result[3]
TB:
  ⍎(0>↑B)/'→TC'
  result←STEP B
  B[0 1 2]←result[0 1 2]
  (2 1⊃C)←(2 1⊃C),⊃result[3]
TC:
  ⍎(0>↑C)/'→TD'
  result←STEP C
  C[0 1 2]←result[0 1 2]
  (2 1⊃D)←(2 1⊃D),⊃result[3]
TD:
  ⍎(0>↑D)/'→TE'
  result←STEP D
  D[0 1 2]←result[0 1 2]
  (2 1⊃E)←(2 1⊃E),⊃result[3]
TE:
  ⍎(0>↑E)/'→TA'
  result←STEP E
  E[0 1 2]←result[0 1 2]
  (2 1⊃A)←(2 1⊃A),⊃result[3]
  return←return,⊃result[3] ⍝ append E's output to result (if present)
  →TA
END:
  return←↑⌽return ⍝ return only the last of E's results
∇

⍝ returns all permutations of 'vec'
∇ result← PERMUTATE vec;sel;fixed;rest;i;result
  ⍝ simplest cases - 0 or 1 elements to permutate
  result ← 1↑⊂vec
  ⍎(1=⍴vec)/'→0'
  ⍎(⍬≡⍴vec)/'→0'

  result←⍬

  ⍝ sel will be a vector of selection vectors
  sel ← 1, ((⍴vec)-1)/0
  sel ← {⍵⌽sel}¨⍳⍴vec

  ⍝ 'fixed' are the fixed elements, 'rest' are those to be permuted
  fixed←{⍵/vec}¨sel
  rest←{(~⍵)/vec}¨sel
  
  i←0
  LOOP:
	  result←result,{(i⊃fixed),⍵}¨PERMUTATE i⊃rest ⍝ prepend each fixed element to all permutations of the rest
	  i←i+1
  ⍎(i<⍴vec)/'→LOOP'
∇

thruster_signals ← ⌽{AMP program ⍵}¨PERMUTATE ⍳5
'Part 1 (max thruster signal):', ⌈/thruster_signals

thruster_signals ← {AMP2 program ⍵}¨5+PERMUTATE ⍳5
'Part 2 (max thruster signal):', ⌈/thruster_signals
'Done.'
)OFF
