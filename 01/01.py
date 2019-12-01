#!/usr/bin/python3
import math
f = open('input', 'r')
masses = [int(x) for x in f.readlines()]
f.close()

i = [math.floor(x/3) - 2 for x in masses]

def total_mass(mass):
    fuel = math.floor(mass/3) - 2
    return mass + (0 if fuel <= 0 else total_mass(fuel))

print("Part 1 answer: {}".format(sum(i)))
print("Part 2 answer: {}".format(sum(map(total_mass, i))))
