def reverse_word(sentence, start, end):
    pass


def reverse(sentence):
    delimiter = "., !;:"
    start = 0
    end = 0
    for count, char in enumerate(sentence):
        if char in delimiter:
            end = count-1
            reverse_word(sentence, start, end)
            start = count + 1


if __name__ == '__main__':
    sentence = "This is new shit"
    reverse(sentence)
    print(sentence)
