def compute_func(x, eps):
    cur_term = x
    result = 0.
    n = 1
    while cur_term > eps:
        result += cur_term
        print(cur_term)
        cur_term *= x**2
        cur_term /= (2*n*(2*n+1))
        n += 1
    return result


if __name__ == "__main__":
    print('Result: {0:0.6f}'.format(compute_func(0.5, 1e-6)))
