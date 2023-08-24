import os
os.environ['LIBROSA_CACHE_DIR'] = 'C:/librosa_cache'


import librosa
import matplotlib.pyplot as plt
from PIL import Image


import sounddevice as sd
import soundfile as sf
import numpy as np

import time

voice = "Silver"
voice_dir = f"data/{voice}/"

filename = f"data/{voice}/01.wav"
output = f"data/{voice}/output.png"

y, sr = librosa.load(filename, sr=None, dtype=np.float32)
duration = librosa.get_duration(y=y,sr=sr)

sample_count = np.size(y)


#f0, vf, fp = librosa.pyin(y=y, fmin=64, fmax=2048)


# sd.play(y, sr)
# sd.wait()


chunk_time = 4
chunk_size = np.shape(np.arange(sr * chunk_time))

length = np.size(y) % sr


chunks = np.array_split(y, chunk_size)

n_fft: int = 2 ** 13
n_mels: int = 1024
hop_length = 256

index=0
for chunk in chunks:
    M = librosa.feature.melspectrogram(y=chunk, sr=sr, n_fft=n_fft, hop_length=hop_length, n_mels=n_mels)
    M_dB = librosa.power_to_db(M, ref=np.max)
    print(M_dB.shape)
    I = np.flip(M_dB, 0)
    plt.imsave(f"data/{voice}/output{index}.png", I)
    index += 1





# im = Image.fromarray(I)

# im.save(output)

# y = librosa.feature.inverse.mel_to_audio(M=M, sr=sr, n_fft=n_fft, hop_length=512)
# sf.write(f"data/{voice}/output.wav", data=y, samplerate=sr)


print(duration)

# plt.plot(range(0, int(sr)), pitch[0])
# plt.show()
