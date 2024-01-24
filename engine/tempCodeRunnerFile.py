input: str = input("Enter text:\n")
    result: list[list[str]] = phonemizer.text_to_phonemes(input, "arpabet")
    output: str = " | ".join([" ".join(word) for word in result])
    result: list[list[str]] = phonemizer.text_to_phonemes(input, "xsampa")
    output1: str = " | ".join([" ".join(word) for word in result])
    result: list[list[str]] = phonemizer.text_to_phonemes(input, "ipa")
    output2: str = " | ".join([" ".join(word) for word in result])

    print(output, output1, output2, sep="\n")