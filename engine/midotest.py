import mido

midi_file = open("data/Silver/test.mid")

result = mido.MidiFile("data/Silver/test.mid")

result.play()

print(result)