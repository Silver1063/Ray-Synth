import time
import math
import numpy as np
import soundfile as sf
import sounddevice as sd
# from PIL import Image
import matplotlib.pyplot as plt
import librosa
import os
os.environ['LIBROSA_CACHE_DIR'] = 'C:/librosa_cache'

voice = "Silver"
voice_dir = f"data/{voice}/"

filename = f"data/{voice}/01.wav"
output = f"data/{voice}/output.png"

y, sr = librosa.load(filename, sr=None, dtype=np.float32)


def main():
    #show_pitch(y, sr)
    
    chunks = split_sample(y, sr)
    M_chunks = generate_mel(chunks)
    y_chunks = synthesize_audio(M_chunks)
    
    y_n = np.concatenate(y_chunks)
    
    sf.write(f"data/{voice}/outputtest.wav", data=y_n, samplerate=sr)


def show_pitch(y, sr):
    f0_hz,_,_ = librosa.pyin(y=y, sr=sr, fmin=64, fmax=2048)
    
    f0_lin = [1200 * math.log2(hz / 440) for hz in f0_hz]
    plt.plot(f0_lin)
    plt.ylim(1200 * math.log2(librosa.note_to_hz('C3') / 440),0)
    plt.show()

chunk_length = int(4.0 * sr)
chunk_overlap = int(0.5 * sr)


def split_sample(y, sr):
    sample_count = np.size(y)

    chunks = []
    index = 0
    while (index < sample_count):
        new_chunk = np.copy(y[index: index+chunk_length])

        if (np.size(new_chunk) != chunk_length):
            new_chunk.resize((chunk_length))

        chunks.append(new_chunk)
        index += (chunk_length-chunk_overlap)
    
    return chunks

def combine_chunks(chunks):    
    if type(chunks) is np.ndarray:
        return chunks
    result = np.concatenate(chunks, axis=0)
    
    print(np.shape(result))
    
    return result

def generate_mel(chunks):
    n_fft = 4096
    hop_length = 1024
    n_mels = 512
    
    if not type(chunks) is list:
        print("here")
        chunks = [chunks]
    M_chunks = []
    index = 0
    for y in chunks:
        print("Generating Mel", index)
        M = librosa.feature.melspectrogram(
            y=y, sr=sr, n_fft=n_fft, hop_length=hop_length, n_mels=n_mels)
    
        M_chunks.append(M)
    
        M_dB = librosa.power_to_db(M, ref=np.max)
        I = np.flip(M_dB, 0)
        plt.imsave(f"data/{voice}/output{index}.png", I)
        index += 1
    
    return M_chunks

def synthesize_audio(chunks):
    n_fft = 4096
    hop_length = 1024
    
    y_chunks = []
    
    if type(chunks) is np.ndarray:
        print("here")
        chunks = [chunks]
    
    index = 0
    for M in chunks:
        print("Generating Audio", index)
        y = librosa.feature.inverse.mel_to_audio(
            M=M, sr=sr, n_fft=n_fft, hop_length=hop_length)
        
        #sf.write(f"data/{voice}/output{index}.wav", data=y, samplerate=sr)
        #sf.write(f"data/{voice}/outputtest.wav", data=y, samplerate=sr)
        index += 1
    
    return y_chunks


if __name__ == "__main__":
    main()
    exit()
    