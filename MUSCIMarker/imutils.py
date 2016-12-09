"""
This module implements several functions for manipulation with images.
"""

import logging
import numpy as np
from PIL import Image


def load_image_gray(filename):
    """
    Loads an image from a given file.
    :param filename: The filename of an image to be read.
    :return: The NumPy array (uint8) of the gray-scaled image with values
    between 0 and 255.
    """
    image = Image.open(filename).convert('L')
    return np.array(image, dtype=np.uint8)


def save_image(filename, image):
    """
    Saves a NumPy array as an image.
    :param filename: Output filename.
    :param image: An image represented by a NumPy.
    """
    image = _image_to_uint8(image)
    Image.fromarray(image).save(filename)


def _image_to_uint8(image):
    """
    Transforms an image represented by a NumPy array (possibly with float
    values) into the corresponding uint8 representation.
    :param image: The input image array to be transformed with non-negative
    values.
    :return: The NumPy array of uint8 representing the input image.
    """
    assert type(image) is np.ndarray, 'Not a valid NumPy array!'

    # Already converted
    if np.issubdtype(image.dtype, np.uint8):
        return image

    if np.issubdtype(image.dtype, np.float):
        i_min, i_max = image.min(), image.max()

        if i_min < 0:
            raise ValueError('Negative image values are not allowed!')

        if i_max == i_min:
            intensity = 1.0 if i_min > 0 else 0.0
            image.fill(intensity)
            logging.warning('Image to uint8: image.max() == image.min()')
        else:
            # Linear normalization to [0, 1] range
            image = (image - i_min) / (i_max - i_min)

        # Conversion to uint8
        return (255 * image).astype(np.uint8)

    else:
        raise TypeError('Unsupported image type {0}!'.format(image.dtype))
