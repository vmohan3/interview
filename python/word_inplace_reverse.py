def reverse_word(sentence, start, end):
    length = end - start + 1
    l_by_2 = (length / 2)
    for i in range(start, start + l_by_2):
        j = end - i + start
        sentence[i], sentence[j] = sentence[j], sentence[i]


def reverse(sentence):
    delimiter = "., !;:'\""
    start = 0
    end = 0
    for count, char in enumerate(sentence):
        if char in delimiter:
            end = count-1
            reverse_word(sentence, start, end)
            start = count + 1


if __name__ == '__main__':
    sentence = 'Dorothy says: "This is new shit!"'
    sentence = list(sentence)
    reverse(sentence)
    sentence = ''.join(sentence)
    print(sentence)
