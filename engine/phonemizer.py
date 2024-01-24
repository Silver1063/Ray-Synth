import re
import csv


class Phonemizer:
    # currently used dictionary
    word2phonemes: dict[str, list[list[str]]] = {}

    # Languages in no particular order
    # English
    ENG_dict: dict[str, list[list[str]]] = {}
    # German
    DEU_dict: dict[str, list[list[str]]] = {}
    # Spanish
    SPA_dict: dict[str, list[list[str]]] = {}
    # French
    FRA_dict: dict[str, list[list[str]]] = {}
    # Japanese
    JPN_dict: dict[str, list[list[str]]] = {}
    # Chinese (Mandarin)
    CMN_dict: dict[str, list[list[str]]] = {}
    # Korean
    KOR_dict: dict[str, list[list[str]]] = {}

    # default language is english
    language: str = "eng"

    ipa2xsampa: dict[str, str] = {}
    xsampa2ipa: dict[str, str] = {}

    arpabet2xsampa: dict[str, str] = {}
    xsampa2arpabet: dict[str, str] = {}

    xsampa2rayvowel: dict[str, list[float]] = {}

    def __init__(self, language: str):
        self.language = language
        self.ENG_dict = self.load_cmu_dict() if self.language == "eng" else {}
        # self.XXX_dict = self.function_loads_language_dictonary() if self.language == "xxx" else {}

        match self.language:
            case "eng":
                self.word2phonemes = self.ENG_dict
            case "deu":
                self.word2phonemes = self.DEU_dict
            case "spa":
                self.word2phonemes = self.SPA_dict
            case "fra":
                self.word2phonemes = self.FRA_dict
            case "jpn":
                self.word2phonemes = self.JPN_dict
            case "cmn":
                self.word2phonemes = self.CMN_dict
            case "kor":
                self.word2phonemes = self.KOR_dict
            case _:
                self.word2phonemes = self.ENG_dict

        with open(file="data/ipa2xsampa.csv", encoding="utf-8", mode="r") as file:
            reader = csv.reader(file)
            for row in reader:
                ipa: str
                xsampa: str
                ipa, xsampa = row
                self.ipa2xsampa[ipa] = xsampa
                self.xsampa2ipa[xsampa] = ipa

        with open(file="data/arpabet2xsampa.csv", encoding="utf-8", mode="r") as file:
            reader = csv.reader(file)
            for row in reader:
                arpabet: str
                xsampa: str
                arpabet, xsampa = row
                self.arpabet2xsampa[arpabet] = xsampa
                self.xsampa2arpabet[xsampa] = arpabet

        with open(file="data/xsampa2rayvowel.csv", encoding="utf-8", mode="r") as file:
            reader = csv.reader(file)
            for i, row in enumerate(reader):
                if row[0] == "VOWEL" or row[0] == "CONSONANT":
                    continue
                xsampa: str = row[0]
                rayvowel: list[float] = [float(eval(elem)) for elem in row[1:4]]
                self.xsampa2rayvowel[xsampa] = rayvowel

    def load_cmu_dict(self) -> dict[str, list[list[str]]]:
        dictionary: dict[str, list[list[str]]] = {}
        with open(file="data/cmudict.csv", encoding="utf-8", mode="r") as file:
            reader = csv.reader(file, delimiter=" ")
            for row in reader:
                key: str = row[0]
                key = re.sub(r"\(\d\)", "", key)

                value: list[str] = [re.sub(r"\d*", "", p.lower()) for p in row[1:]]
                value = value if not "#" in value else value[0 : value.index("#")]

                if key in dictionary:
                    current = dictionary[key]
                    dictionary[key] = current + [value]
                else:
                    dictionary[key] = [value]
        return dictionary

    def clean_text(self, text: str) -> str:
        clean_text = re.sub(r"[^a-zA-Z'\s]", "", text).lower()
        return clean_text

    def text_to_phonemes(self, text: str, format: str = "xsampa") -> list[list[str]]:
        clean_text = re.sub(r"[^a-zA-Z'\s]", "", text).lower()

        phonemes = []
        for word in clean_text.split():
            phonemes = phonemes + [self.word_to_phonemes(word, format)]

        return phonemes

    def word_to_phonemes(self, word: str, format: str = "xsampa") -> list[str]:
        phonemes: list[str] = ["n/a"]

        # todo select alternate pronunciations [word][0],[1],etc
        if word in self.word2phonemes:
            phonemes = self.word2phonemes[word][0]

        if format == "xsampa":
            phonemes = [self.arpabet2xsampa[phoneme.upper()] for phoneme in phonemes]
            phonemes = self.parse_xsampa("".join(phonemes))

        if format == "ipa":
            phonemes = [self.arpabet2xsampa[phoneme.upper()] for phoneme in phonemes]
            phonemes = self.parse_xsampa("".join(phonemes))
            phonemes = [self.xsampa2ipa[phoneme] for phoneme in phonemes]

        return phonemes

    def phonemes_to_rays(
        self, phonemes: list[str], format: str = "xsampa"
    ) -> list[list[float]]:
        rays: list = []
        ray: list[float] = []
        for phoneme in phonemes:
            if phoneme in self.xsampa2rayvowel:
                ray = self.xsampa2rayvowel[phoneme]
            else:
                ray = [0.0]
            rays.append(ray)
        return rays

    def parse_xsampa(self, text: str) -> list[str]:
        # get each character and remove whitespace
        chars: list[str] = [*text.replace(" ", "")]

        postfixes: list[str] = ["\\", "`"]
        prefixes: list[str] = ["_"]

        # check for multi character phonemes
        for postfix in postfixes:
            while postfix in chars:
                i = chars.index(postfix)
                chars[i - 1] = chars[i - 1] + postfix
                chars.remove(postfix)

        for prefix in prefixes:
            while prefix in chars:
                i = chars.index(prefix)
                chars[i + 1] = prefix + chars[i + 1]
                chars.remove(prefix)

        return chars

    def parse_ipa(self, text: str):
        return text.split()

    def parse_arpabet(self, text: str):
        return text.split()


if __name__ == "__main__":
    p: Phonemizer = Phonemizer("eng")

    input: str = input("Enter text:\n")
    arpabet: list[list[str]] = p.text_to_phonemes(input, "arpabet")
    output: str = " | ".join([" ".join(word) for word in arpabet])
    xsampa: list[list[str]] = p.text_to_phonemes(input, "xsampa")
    output1: str = " | ".join([" ".join(word) for word in xsampa])
    ipa: list[list[str]] = p.text_to_phonemes(input, "ipa")
    output2: str = " | ".join([" ".join(word) for word in ipa])

    print(output, output1, output2, sep="\n")

    print([p.phonemes_to_rays(x) for x in xsampa])
