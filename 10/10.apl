#!/usr/local/bin/apl -s

⎕IO←0 ⍝ index from 0
DISPLAY ← {4⎕CR⍵}
GET_LINES ← {⎕FIO[49]⍵}

⍝ global variables 
filename ← {⍵[0;]}⊃¯1↑⎕ARG

'Loading input ', filename

input ← ⊃GET_LINES filename

d ← DISPLAY 
(h w) ← ⍴input

'Loaded map' w '×' h ':'
d input

∇ return←gcd args; a; b
  (a b) ← args
  return ← a
  ⍎(a=b)/'→0'
  →(A B)[a<b]
  A: return←gcd (a-b) b
  →0
  B:return←gcd a (b-a)
  →0
∇

asteroids←'#'⍷input

∇ return ← valid_coords args; map; x; y; lx; ly
  (map pos) ← args
  (x y) ← ⊃pos
  (ly lx) ← ⍴map

  return ← 0
  ⍎(∨/ (x<0) (y<0) (x ≥ lx) (y ≥ ly))/'→0'

  return ← 1
∇

∇ return ← gen_invi args; map; posa; posb; x; y; k
  (map posa posb) ← args
  return ← map
  (x y) ← posb
  ⍎(~map[y;x])/'→0'

  return ← (⍴map)⍴1
  vector ← posb - posa

  ⍎(∧/ vector = (0 0))/'→0'

  ⍎(∧/{⍵≠0}¨vector)/'divisor ← gcd (|vector)'
  ⍎(~∧/{⍵≠0}¨vector)/'divisor ← +/|vector'

  vector ← vector ÷ divisor

  k ← 1
  L:
  position ← posb + k×vector
  ⍎(~valid_coords map position)/'→0'

  return[(position[1]); (position[0])] ← 0

  k ← k + 1
  → L
∇

∇ return ← visibility_from args; map; pos; x; y; tmp
  (map pos) ← args
  (x y) ← ⊃pos

  tmp ← (⍴map)⍴1

  ⊣{tmp ← tmp ∧ gen_invi map (x y) ⍵}¨((×/⍴map)⍴⍳⌽⍴map)
  return ← tmp
∇

∇ return ← number_of_visible_from args; map; pos
  (map pos) ← args
  return ← 0
  ⍎(~map[pos[1];pos[0]])/'→0'
  return ← ¯1 + +/+/ map ∧ visibility_from map pos
∇


visibility_matrix ← (⍳h) ∘.{number_of_visible_from asteroids (⍵ ⍺)} ⍳w
part1 ← ⌈/⌈/ visibility_matrix
'Part 1:' part1

vis_vec ←(h×w)⍴part1⍷visibility_matrix
monitoring_station_location ← ↑⌽vis_vec/(h×w)⍴⍳h w ⍝ monitoring station location - [x, y] position with the highest number of visible asteroids
'Monitoring station location: ' monitoring_station_location


len ← {(+/{⍵*2}⍵)*0.5} ⍝ vector length

⍝ gets angle according to y axis, clock-wise (north = 0, east = 0.5 pi, west = 1.5pi)
∇ return ← get_angle_OLD pos
  (dx dy) ← pos
  v0 ← 0 ¯1 ⍝ y axis vector
  base ← 0
  ⍎(dx<0)/'dx←-dx◊dy←-dy◊base←○1' ⍝ if the the point is in 3-rd or 4-th quadrant, add pi and mirror by origin
  return ← base + ¯2○(+/v0 × pos)÷(len pos) ⍝ base + vector angle
∇

∇ return ← get_angle pos
  (dx dy) ← pos
  v0 ← 0 ¯1 ⍝ y axis vector
  base ← 0
  ⍎(dx<0)/'pos←-pos◊base←○1' ⍝ if the the point is in 3-rd or 4-th quadrant, add pi and mirror by origin
  return ← base + ¯2○(+/v0 × pos)÷(len pos) ⍝ base + vector angle
∇

total←h×w
⍝ override monitoring_station_location with the 'X'
⍝asteroids[monitoring_station_location[0];monitoring_station_location[1]]←'X'
⍝monitoring_station_location←⌽↑(total⍴'X'⍷input)/(total⍴⍳h w)
⍝'OVERRIDEN Monitoring station location: ' monitoring_station_location

msl←monitoring_station_location

∇SHOOT asteroids
  i←1
  prev_angle ← ¯1

  ⍝ clear the monitoring station position
  asteroids[msl[0];msl[1]]←0
  
LOOP:
  ⍎(~∨/∨/asteroids)/'→0' ⍝ if no asteroids are left, finish

  rel_angles ← get_angle¨{⌽(-msl)+⍵}¨⍳h w
  rel_angles ← rel_angles ⌈ 1000×~asteroids ⍝ put 1000 as a relative angle for positions without asteroids - that way they will be always listed as the last
  rel_angles ← rel_angles ⌈ 1000 × rel_angles ≤ prev_angle ⍝ put 1000 as a relative angle for all positions with angle LE than previosly vanished. The gun has to increase the angle between vanishes
  ⍝ asteroids to be vanished next - those with the smallest strictly greater angle than the last run...
  next_to_vanish_angle ← ⌊/total⍴rel_angles
  ⍎(next_to_vanish_angle > 7)/'prev_angle←¯1◊→LOOP'⍝ if we finished loop (the highest angle is 2pi), set angle to negative and goto beginning

  candidates ← (total ⍴ next_to_vanish_angle ⍷ rel_angles)/total⍴⍳h w
  
  distsq2 ← +/¨ {⍵*2} candidates - ⊂msl ⍝ squared distances to monitoring station; all distances are larger or equal to 1, so don't have to bother with square root
  
  ⍝... and from them the one closest to
  cand_index ← ↑⍋distsq2
  next_to_vanish ← cand_index⊃candidates
  'Vanishing' (⌽next_to_vanish)
  asteroids[next_to_vanish[0]; next_to_vanish[1]]←0 ⍝ vanish

'Turn #',i,', ' (+/+/asteroids) ' asteroids left:'
  DISPLAY '.#'[asteroids]
  
  prev_angle ← next_to_vanish_angle
  i←i+1
  →LOOP
∇

SHOOT asteroids

'Done.'
)OFF
