"""
This modules serves as a wrapper for problematic skimage functions. It allows
to use the original functions without any change on platforms, where skimage
is available. On platforms where skimage is not available, the application will
use special package 'cimutils' containing the manually transformed equivalents.
"""

try:
    # Try to use skimage (if it is available)
    from skimage.draw import line, polygon
    from skimage.measure import label
except ImportError:
    # Otherwise (e.g. on Android), cimutils will be compiled and prepared
    from cimutils import line, polygon, label
