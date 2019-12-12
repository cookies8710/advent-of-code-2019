#!/usr/local/bin/apl -s

⎕IO←0 ⍝ index from 0
DISPLAY ← {4⎕CR⍵}

d←DISPLAY

⍝ applies gravitation on positions - first computes outer product of signum of positions differences, then sums them to get total gravitation effect
apply_gravity←{+/⍵∘.{×⍵-⍺}⍵}

⍝positions←(¯1 0 2) (2 ¯10 ¯7) (4 ¯8 8) (3 5 ¯1)
⍝positions←(¯8 ¯10 0) (5 5 10) (2 ¯7 3) (9 ¯8 ¯3)
positions←(¯8 ¯9 ¯7) (¯5 2 ¯1) (11 8 ¯14) (1 ¯4 ¯11)
steps ← 1000

⍝ velocities are 0 at the beginning - 4 × (0 0 0)
velocities←4/⊂3/0

⍝ next step in simulation
∇ result ← next args; positions; velocities
  (positions velocities) ← args
  velocities ← velocities + apply_gravity positions
  positions ← positions + velocities
  result ← positions velocities
∇

⍝ executes desired number of steps
∇ result ← execute args; positions; velocities; steps
  (positions velocities steps) ← args
  L:
  (positions velocities)←next positions velocities
  steps ← steps - 1
  ⍎(steps > 0)/'→L'
  result ← positions velocities
∇

(part1_positions part1_velocities)←execute positions velocities steps
'State after' steps 'steps:'
'Positions:'
DISPLAY part1_positions
'Velocities:'
DISPLAY part1_velocities
'Part 1 (total energy):', +/({+/|⍵}¨part1_velocities) × ({+/|⍵}¨ part1_positions)

⍝ executes until the positions on given axis match starting position
∇ result ← execute2 args; positions; velocities; steps; ea; op; ov
  (positions velocities axis) ← args
  (op ov) ←(positions velocities)
  ea←{{⍵[axis]}¨⍵}
  end ← 0
  steps ← 1
  L:
  (positions velocities)←next positions velocities
  steps ← steps + 1
  end ← (ea op)≡(ea positions)
  ⍎(~end)/'→L'
  result ← steps
∇

∇ return ← gcd args; a; b
  (a b) ← args
  return ← a
  ⍎(a=b)/'→0'
  →(A B)[b > a]
  A:
  return ← gcd (a-b) b
  →0
  B:
  return ← gcd a (b-a)
∇

⍝lcm ← {1↑1↓(⍺×⍳⍵)∩(⍵×⍳⍺)}  ⍝ todo improve
lcm ← {(⍺×⍵)÷(gcd ⍺ ⍵)}
'Part 2:', lcm/{execute2 positions velocities ⍵}¨⍳3

'Done.'
)OFF
