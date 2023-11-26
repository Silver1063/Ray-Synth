import math
import numpy as np
import soundfile as sf
# import sounddevice as sd
# from PIL import Image
import matplotlib.pyplot as plt
import librosa
import os

#os.environ["LIBROSA_CACHE_DIR"] = "C:/librosa_cache"

voice: str = "Silver"
# voice_dir = f"data/{voice}/"

filename: str = f"data/{voice}/01.wav"


n_fft: int = 4096
hop_length: int = 512
n_mels: int = 512

y: np.ndarray
sr: float

y, sr = librosa.load(filename, sr=None, dtype=np.float32)

chunk_length: int = int(4.0 * sr)
chunk_overlap: int = int(0.5 * sr)


def main() -> None:
    show_pitch(y, sr)
    
    chunks: list[np.ndarray] = split_sample(y)
    M_chunks: list[np.ndarray] = generate_melspectrogram_chunks(chunks)
    y_chunks: list[np.ndarray] = synthesize_audio(M_chunks)
    
    # MFCC_chunks: list[np.ndarray] = generate_MFCC_chunks(chunks)
    # y_chunks: list[np.ndarray] = synthesize_audio_from_mfcc(MFCC_chunks)
    
    
    render: np.ndarray = combine_chunks(y_chunks)

    sf.write(f"data/{voice}/output.wav", data=render, samplerate=sr)


def show_pitch(y: np.ndarray, sr: float) -> None:
    f0, voiced_flag, voiced_probs = librosa.pyin(y=y, sr=sr, fmin=64, fmax=2048)
    cents = [1200 * math.log2(hz / 440) for hz in f0]
    plt.plot(cents)
    plt.ylim(1200 * math.log2(librosa.note_to_hz("C3") / 440), 0)
    plt.show()


def split_sample(y: np.ndarray) -> list:
    sample_count = np.size(y)

    chunks: list[np.ndarray] = []
    index = 0
    while index < sample_count:
        new_chunk = np.copy(y[index : index + chunk_length])

        if np.size(new_chunk) != chunk_length:
            new_chunk.resize((chunk_length))

        chunks.append(new_chunk)
        index += chunk_length - chunk_overlap

    return chunks


def combine_chunks(chunks: list[np.ndarray]):
    # why this look like haskell kinda
    fst: np.ndarray = chunks[0]
    fst = fade_out(fst)

    mid: list = chunks[1:-1]
    mid = [fade_inout(y) for y in mid]

    lst: np.ndarray = chunks[-1]
    lst = fade_in(lst)

    chunks = [fst] + mid + [lst]

    y_n: np.ndarray = np.empty_like(fst)

    for i, chunk in enumerate(chunks):
        gap: int = chunk_length - chunk_overlap
        padded: np.ndarray = np.pad(chunk, (i * gap, 0))
        y_n.resize(np.shape(padded))
        y_n += padded

    return y_n


def fade_in(y: np.ndarray) -> np.ndarray:
    ones: np.ndarray = np.ones((chunk_length - chunk_overlap,))
    ramp: np.ndarray = np.linspace(-(math.pi / 2), 0, chunk_overlap)
    ramp = np.cos(ramp)
    fade: np.ndarray = np.concatenate([ramp, ones])
    return y * fade


def fade_out(y: np.ndarray) -> np.ndarray:
    ones: np.ndarray = np.ones((chunk_length - chunk_overlap,))
    ramp: np.ndarray = np.linspace(0, (math.pi / 2), chunk_overlap)
    ramp = np.cos(ramp)
    fade: np.ndarray = np.concatenate([ones, ramp])
    return y * fade


def fade_inout(y: np.ndarray) -> np.ndarray:
    return fade_out(fade_in(y))


def generate_melspectrogram_chunks(chunks) -> list:
    M_chunks: list[np.ndarray] = []
    index: int = 0
    for y in chunks:
        print("Generating Mel", index)
        M: np.ndarray = librosa.feature.melspectrogram(
            y=y, sr=sr, n_fft=n_fft, hop_length=hop_length, n_mels=n_mels
        )

        M_chunks.append(M)
        index += 1
        M_dB = librosa.power_to_db(M, ref=np.max)
        I = np.flip(M_dB, 0)
        plt.imsave(f"data/{voice}/output{index}.png", I)

    return M_chunks

def generate_MFCC_chunks(chunks) -> list:
    MFCC_chunks: list[np.ndarray] = []
    index: int = 0
    for y in chunks:
        print("Generating MFCC", index)
        MFCC: np.ndarray = librosa.feature.mfcc(
            y=y, sr=sr, n_mfcc=40, n_fft=n_fft, hop_length=hop_length, n_mels=n_mels
        )

        MFCC_chunks.append(MFCC)
        index += 1
        # M_dB = librosa.power_to_db(M, ref=np.max)
        I = np.flip(MFCC, 0)
        plt.imsave(f"data/{voice}/output{index}.png", I)

    return MFCC_chunks


def synthesize_audio(chunks) -> list:
    y_chunks: list[np.ndarray] = []

    for i, M in enumerate(chunks):
        print("Generating Audio", i)
        y: np.ndarray = librosa.feature.inverse.mel_to_audio(
            M=M, sr=sr, n_fft=n_fft, hop_length=hop_length
        )
        y_chunks.append(y)

    return y_chunks


def synthesize_audio_from_mfcc(chunks) -> list:
    y_chunks: list[np.ndarray] = []

    index: int = 0
    for i, MFCC in enumerate(chunks):
        print("Generating Audio", i)
        y: np.ndarray = librosa.feature.inverse.mfcc_to_audio(
            mfcc=MFCC, sr=sr, n_fft=n_fft, hop_length=hop_length
        )

        y_chunks.append(y)

    return y_chunks


if __name__ == "__main__":
    main()
    exit()
