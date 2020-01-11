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

asteroids←'#'⍷input

⍝ returns 1 iff the passed coordinates are valid for given map
∇ return ← valid_coords args; map; x; y; lx; ly
  (map pos) ← args
  (x y) ← ⊃pos
  (ly lx) ← ⍴map
  return ← 0
  ⍎(∨/ (x<0) (y<0) (x ≥ lx) (y ≥ ly))/'→0'
  return ← 1
∇

⍝ returns invisibility mask - assuming the observer on posa an an asteroid on posb, it will return map with 0 on places shadowed by the asteroid
∇ return ← gen_invi args; map; posa; posb; x; y; k
  (map posa posb) ← args
  return ← map
  (x y) ← posb
  ⍎(~map[y;x])/'→0' ⍝ no asteroid on posb, nothing to do

  return ← (⍴map)⍴1 ⍝ initial map is full of 1

  ⍝ compute vector between posb and posa
  vector ← posb - posa
  ⍎(∧/ vector = (0 0))/'→0' ⍝ null vector means posb=posa, nothing to do

  ⍝ find divisor - greatest number D s.t. vector÷D is a vector with integral components; e.g. 2 for ¯4 2, 7 for 7 1, 5 for 15 ¯10
  ⍝ (note that the code below works only in 2D)
  ⍎(∧/{⍵≠0}¨vector)/'divisor ← ∨/|vector' ⍝ for vector which isn't parallel with any axis - GCD of components
  ⍎(~∧/{⍵≠0}¨vector)/'divisor ← +/|vector' ⍝ otherwise the nonnull component

  ⍝ get unit vector
  vector ← vector ÷ divisor

  k ← 1
  L:
  position ← posb + k×vector
  ⍎(~valid_coords map position)/'→0'
  return[position[1]; position[0]] ← 0
  k ← k + 1
  → L
∇

⍝ generates visibility mask from given position
∇ return ← visibility_from args; map; pos; x; y; tmp
  (map pos) ← args
  (x y) ← ⊃pos

  tmp ← (⍴map)⍴1

  ⍝ generate invisibility masks for all positions and AND them
  ⊣{tmp ← tmp ∧ gen_invi map (x y) ⍵}¨((×/⍴map)⍴⍳⌽⍴map)
  return ← tmp
∇

⍝ returns number of visible asteroids from given position
∇ return ← number_of_visible_from args; map; pos
  (map pos) ← args
  return ← 0
  ⍎(~map[pos[1];pos[0]])/'→0' ⍝ no asteroid on passed position, nothing to do
  return ← ¯1 + +/+/ map ∧ visibility_from map pos ⍝ otherwise AND the visibility mask with map, sum up the visible asteroids and subtract 1 (the asteroid on passed position should not be counted)
∇

⍝ compute number of visible asteroids for all positions
visibility_matrix ← (⍳h) ∘.{number_of_visible_from asteroids (⍵ ⍺)} ⍳w
⍝ get the max number of visible asteroids
part1 ← ⌈/⌈/ visibility_matrix
'Part 1:' part1

vis_vec ←(h×w)⍴part1⍷visibility_matrix
monitoring_station_location ← ↑⌽vis_vec/(h×w)⍴⍳h w ⍝ monitoring station location - [x, y] position with the highest number of visible asteroids
'Monitoring station location: ' monitoring_station_location

len ← {(+/{⍵*2}⍵)*0.5} ⍝ vector length

⍝ gets angle according to y axis, clock-wise (north = 0, east = 0.5 pi, west = 1.5pi)
∇ return ← get_angle pos
  v0 ← 0 ¯1 ⍝ y axis vector
  base ← 0
  ⍎((↑pos)<0)/'pos←-pos◊base←○1' ⍝ if the the point is in 3-rd or 4-th quadrant, add pi and mirror by origin
  return ← base + ¯2○(+/v0 × pos)÷(len pos) ⍝ base + vector angle
∇

total←h×w

⍝ starts with the gun heading north, shoots asteroids while turning clockwise until no asteroids are left
∇ SHOOT asteroids
  turn←1
  prev_angle ← ¯1

  ⍝ clear the monitoring station position
  asteroids[monitoring_station_location[0];monitoring_station_location[1]]←0
  
LOOP:
  ⍎(~∨/∨/asteroids)/'→0' ⍝ if no asteroids are left, finish

  rel_angles ← get_angle¨{⌽(-monitoring_station_location)+⍵}¨⍳h w
  rel_angles ← rel_angles ⌈ 1000×~asteroids ⍝ put 1000 as a relative angle for positions without asteroids - that way they will be always listed as the last
  rel_angles ← rel_angles ⌈ 1000 × rel_angles ≤ prev_angle ⍝ put 1000 as a relative angle for all positions with angle LE than previosly vanished. The gun has to increase the angle between vanishes

  ⍝ asteroids to be vanished next - those with the smallest strictly greater angle than the last run...
  next_to_vanish_angle ← ⌊/total⍴rel_angles

  ⍎(next_to_vanish_angle > 7)/'prev_angle←¯1◊→LOOP'⍝ if we finished loop (the highest angle is 2pi), set angle to negative and goto beginning

  ⍝ vanish candidates - those asteroids with the same next_to_vanish_angle
  candidates ← (total ⍴ next_to_vanish_angle ⍷ rel_angles)/total⍴⍳h w
  
  distsq2 ← +/¨ {⍵*2} candidates - ⊂monitoring_station_location ⍝ squared distances to monitoring station; all distances are larger or equal to 1, so don't have to bother with square root
  
  ⍝... and from them the one closest to
  cand_index ← ↑⍋distsq2
  next_to_vanish ← cand_index⊃candidates
  'Vanishing' (⌽next_to_vanish)
  asteroids[next_to_vanish[0]; next_to_vanish[1]]←0 ⍝ vanish

  'Turn #',turn,', ' (+/+/asteroids) ' asteroids left:'
  DISPLAY '.#'[asteroids]
  
  prev_angle ← next_to_vanish_angle
  turn←turn+1
  →LOOP
∇

SHOOT asteroids

'Done.'
)OFF
