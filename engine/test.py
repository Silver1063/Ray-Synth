import matplotlib.pyplot as plt
import matplotlib.collections as mplc
import numpy as np

# Create a quadmesh.
x = np.linspace(0, 1, 100)
y = np.linspace(0, 1, 100)
z = np.sin(x * y)
quadmesh = mplc.QuadMesh(x, y, z)
# Convert the quadmesh to an array-like object.
array = quadmesh.get_array()

# Save the array as an image.
plt.imsave('my_image.png', array)