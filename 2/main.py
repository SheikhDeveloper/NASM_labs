
def insertions_with_bin_search_sort(nums: list[int], reversed: bool) -> list[int]:
    """
    >>> insertions_with_bin_search_sort([3, 2, 1], True)
    [3, 2, 1]
    >>> insertions_with_bin_search_sort([3, 2, 1], False)
    [1, 2, 3]
    >>> insertions_with_bin_search_sort([3, 2, 1], True)
    [3, 2, 1]
    >>> insertions_with_bin_search_sort([3, 2, 1], False)
    [1, 2, 3]
    >>> insertions_with_bin_search_sort([3, 5, 100500, -1, 7, 0], False)
    [-1, 0, 3, 5, 7, 100500]
    """
    for i in range(len(nums)):
        left = 0
        right = i + 1
        while left < right:
            middle = (left + right) // 2
            if not reversed:
                if nums[middle] < nums[i]:
                    left = middle + 1
                else:
                    right = middle
            else:
                if nums[middle] > nums[i]:
                    left = middle + 1
                else:
                    right = middle
        num = nums[i]
        for j in range(i, left, -1):
            nums[j] = nums[j - 1]
        nums[left] = num
    return nums


if __name__ == "__main__":
    import doctest

    doctest.testmod()
