import time
import numpy as np
import soundfile as sf
import sounddevice as sd
#from PIL import Image
import matplotlib.pyplot as plt
import librosa
import os
os.environ['LIBROSA_CACHE_DIR'] = 'C:/librosa_cache'


voice = "Silver"
voice_dir = f"data/{voice}/"

filename = f"data/{voice}/01.wav"
output = f"data/{voice}/output.png"

y, sr = librosa.load(filename, sr=None, dtype=np.float32)
duration = librosa.get_duration(y=y, sr=sr)
sample_count = np.size(y)


f0,_,_ = librosa.pyin(y=y, sr=sr, fmin=64, fmax=2048)
plt.plot(f0)
plt.show()


chunk_length = int(4.0 * sr)
chunk_overlap = int(0.5 * sr)


chunks = []
index = 0
while (index < sample_count):
    new_chunk = np.copy(y[index: index+chunk_length])
    
    if(np.size(new_chunk) != chunk_length):
        new_chunk.resize((chunk_length))
    
    chunks.append(new_chunk)
    index += (chunk_length-chunk_overlap)



M_chunks = []

index = 0
for y in chunks:
    M = librosa.feature.melspectrogram(y=y, sr=sr)
    M_chunks.append(M)
    
    M_dB = librosa.power_to_db(M, ref=np.max)
    I = np.flip(M_dB, 0)
    plt.imsave(f"data/{voice}/output{index}.png", I)
    index += 1

index = 0
for M in M_chunks:
    y = librosa.feature.inverse.mel_to_audio(M=M, sr=sr)
    sf.write(f"data/{voice}/output{index}.wav", data=y, samplerate=sr)
    index += 1



# 
