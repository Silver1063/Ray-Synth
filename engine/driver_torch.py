import math
import matplotlib as plt
import matplotlib.pyplot as plt

import soundfile as sf

import librosa

import torch

from torch import Tensor
from torchaudio.transforms import MelSpectrogram
from torchaudio.transforms import InverseMelScale
from torchaudio.transforms import GriffinLim

import torchaudio
import torchaudio.functional as F
import torchaudio.transforms as T


voice: str = "Silver"
path: str = f"data/{voice}/"


# SAMPLE_SPEECH = download_asset("tutorial-assets/Lab41-SRI-VOiCES-src-sp0307-ch127535-sg0042.wav")


def plot_waveform(waveform, sr, title="Waveform", ax=None):
    waveform = waveform.numpy()

    num_channels, num_frames = waveform.shape
    time_axis = torch.arange(0, num_frames) / sr

    if ax is None:
        _, ax = plt.subplots(num_channels, 1)
    ax.plot(time_axis, waveform[0], linewidth=1)
    ax.grid(True)
    ax.set_xlim([0, time_axis[-1]])
    ax.set_title(title)


def plot_spectrogram(specgram, title=None, ylabel="freq_bin", ax=None):
    if ax is None:
        _, ax = plt.subplots(1, 1)
    if title is not None:
        ax.set_title(title)
    ax.set_ylabel(ylabel)
    ax.imshow(
        librosa.power_to_db(specgram),
        origin="lower",
        aspect="auto",
        interpolation="nearest",
    )


def main() -> None:

    fname: str = "01.wav"

    y: Tensor
    sr: int
    y, sr = torchaudio.load(f"{path}/{fname}") # type: ignore
    
    print(y.shape, y.dtype)

    n_mels: int = 512
    n_fft: int = 1024 * 16
    n_stft: int = n_fft // 2 + 1

    ms: int = 24
    win_length: int = round(sr * ms / 1000)
    hop_length: int = win_length // 4

    transform_to_M: MelSpectrogram = MelSpectrogram(
        sample_rate=sr,
        n_fft=n_fft,
        n_mels=n_mels,
        win_length=win_length,
        hop_length=hop_length,
    )

    transform_to_S: InverseMelScale = InverseMelScale(
        sample_rate=sr,
        n_stft=n_stft,
        n_mels=n_mels,
    )

    transform_to_y: GriffinLim = GriffinLim(
        n_fft=n_fft,
        win_length=win_length,
        hop_length=hop_length,
    )

    print("Generating MelSpectrogram")
    M: Tensor = transform_to_M(y)

    print("Generating Spectrogram")
    S: Tensor = transform_to_S(M)
    
    print("Generating Audio")
    y: Tensor = transform_to_y(S)

    

    torchaudio.save(uri=f"{path}/output_torchaudio.wav", src=y, sample_rate=sr)  # type: ignore

    # n_stft: int = (n_fft // 2) + 1

    # Visualizations
    visualize: bool = True
    if visualize:
        fig, axs = plt.subplots(2, 1)
        # plot_waveform(y, sr, title="Original waveform", ax=axs[0])
        plot_spectrogram(M[0], title="Mel Spectrogram", ax=axs[0])
        plot_spectrogram(S[0], title="Spectrogram", ax=axs[1])
        # plot_waveform(y, sr, title="Reconstructed waveform", ax=axs[3])
        fig.tight_layout()
        plt.show()


if __name__ == "__main__":
    main()
    quit()
