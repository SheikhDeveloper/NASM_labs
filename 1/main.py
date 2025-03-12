import sys

a, b, c, d, e = [int(x) for x in sys.stdin.read().split()]
print((d * a) / (a + b * c) + (d + b) / (e - a))
