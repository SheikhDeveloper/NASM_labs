import sys

#a, b, c, d, e = [int(x) for x in sys.stdin.read().split()]
a = 2**15 - 1
b = 2**15 - 1
c = 2 ** 31 - 1
d = 2 ** 30 - 1
e = 2 ** 31 - 1
print(a,b,c,d,e, sep='\n')
print((d * a))
print((a + b * c))
print((d * a) // (a + b * c))
print((d + b))
print((e - a))
print((d + b) // (e - a))
print((d * a) // (a + b * c) + (d + b) // (e - a))
