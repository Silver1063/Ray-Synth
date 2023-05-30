from scipy.io import wavfile
import numpy
import pyaudio


SAMPLERATE: int = 48000
CHANNELS: int = 1
FORMAT: int = pyaudio.paFloat32
CHUNK: int = 1024


def main() -> None:
    pa: pyaudio.PyAudio = pyaudio.PyAudio()

    stream: pyaudio.Stream = pa.open(
        rate=SAMPLERATE,
        channels=CHANNELS,
        format=FORMAT,
        output=True,
        frames_per_buffer=CHUNK,
    )

    data = numpy.concatenate((generate_sine_wave("A4", 2),))

    stream.write(data.tobytes())

    # wavfile.write("Engine/output.wav", SAMPLERATE, data)

    stream.stop_stream()
    stream.close()

    pa.terminate()


def generate_sine_wave(pitch: str = "C4", duration: float = 1.0) -> numpy.ndarray:
    A4: float = 440.0

    key_offset: int = {
        "C": -9,
        "D": -7,
        "E": -5,
        "F": -4,
        "G": -2,
        "A": 0,
        "B": 2,
    }[pitch[0]]

    accidental_offset: int = pitch.count("#") - pitch.count("b")

    octave_offset: int = 12 * (int(pitch[-1]) - 4)

    offset: int = key_offset + accidental_offset + octave_offset

    frequency: float = A4 * (2 ** (offset / 12))

    length = int(SAMPLERATE * duration)

    volume: float = 0.05

    data: numpy.ndarray = volume * numpy.sin(
        2
        * numpy.pi
        * frequency
        * numpy.arange(length, dtype=numpy.float32)
        / SAMPLERATE
    )

    return data


def generate_silence(duration: float = 1.0) -> numpy.ndarray:
    length: int = int(SAMPLERATE * duration)
    data: numpy.ndarray = numpy.zeros(length, dtype=numpy.float32)
    return data


if __name__ == "__main__":
    main()
