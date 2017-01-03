#cython: cdivision=True
#cython: boundscheck=False
#cython: nonecheck=False
#cython: wraparound=False
#import math
import numpy as np

cimport numpy as cnp
from libc.math cimport ceil
from ._shared cimport point_in_polygon


def _line(Py_ssize_t r0, Py_ssize_t c0, Py_ssize_t r1, Py_ssize_t c1):
    """Generate line pixel coordinates.

    Parameters
    ----------
    r0, c0 : int
        Starting position (row, column).
    r1, c1 : int
        End position (row, column).

    Returns
    -------
    rr, cc : (N,) ndarray of int
        Indices of pixels that belong to the line.
        May be used to directly index into an array, e.g.
        ``img[rr, cc] = 1``.
    """

    cdef char steep = 0
    cdef Py_ssize_t r = r0
    cdef Py_ssize_t c = c0
    cdef Py_ssize_t dr = abs(r1 - r0)
    cdef Py_ssize_t dc = abs(c1 - c0)
    cdef Py_ssize_t sr, sc, d, i

    with nogil:
        if (c1 - c) > 0:
            sc = 1
        else:
            sc = -1
        if (r1 - r) > 0:
            sr = 1
        else:
            sr = -1
        if dr > dc:
            steep = 1
            c, r = r, c
            dc, dr = dr, dc
            sc, sr = sr, sc
        d = (2 * dr) - dc

    cdef Py_ssize_t[::1] rr = np.zeros(int(dc) + 1, dtype=np.intp)
    cdef Py_ssize_t[::1] cc = np.zeros(int(dc) + 1, dtype=np.intp)

    with nogil:
        for i in range(dc):
            if steep:
                rr[i] = c
                cc[i] = r
            else:
                rr[i] = r
                cc[i] = c
            while d >= 0:
                r = r + sr
                d -= 2 * dc

            c = c + sc
            d += 2 * dr

        rr[dc] = r1
        cc[dc] = c1

    return np.asarray(rr), np.asarray(cc)

def _polygon(r, c, shape):
    """Generate coordinates of pixels within polygon.

    Parameters
    ----------
    r : (N,) ndarray
        Row coordinates of vertices of polygon.
    c : (N,) ndarray
        Column coordinates of vertices of polygon.
    shape : tuple
        Image shape which is used to determine the maximum extent of output
        pixel coordinates. This is useful for polygons that exceed the image
        size. If None, the full extent of the polygon is used.

    Returns
    -------
    rr, cc : ndarray of int
        Pixel coordinates of polygon.
        May be used to directly index into an array, e.g.
        ``img[rr, cc] = 1``.
    """
    r = np.asanyarray(r)
    c = np.asanyarray(c)

    cdef Py_ssize_t nr_verts = c.shape[0]
    cdef Py_ssize_t minr = int(max(0, r.min()))
    cdef Py_ssize_t maxr = int(ceil(r.max()))
    cdef Py_ssize_t minc = int(max(0, c.min()))
    cdef Py_ssize_t maxc = int(ceil(c.max()))

    # make sure output coordinates do not exceed image size
    if shape is not None:
        maxr = min(shape[0] - 1, maxr)
        maxc = min(shape[1] - 1, maxc)

    cdef Py_ssize_t r_i, c_i

    # make contiguous arrays for r, c coordinates
    cdef cnp.ndarray contiguous_rdata, contiguous_cdata
    contiguous_rdata = np.ascontiguousarray(r, dtype=np.double)
    contiguous_cdata = np.ascontiguousarray(c, dtype=np.double)
    cdef cnp.double_t* rptr = <cnp.double_t*>contiguous_rdata.data
    cdef cnp.double_t* cptr = <cnp.double_t*>contiguous_cdata.data

    # output coordinate arrays
    cdef list rr = list()
    cdef list cc = list()

    for r_i in range(minr, maxr+1):
        for c_i in range(minc, maxc+1):
            if point_in_polygon(nr_verts, cptr, rptr, c_i, r_i):
                rr.append(r_i)
                cc.append(c_i)

    return np.array(rr, dtype=np.intp), np.array(cc, dtype=np.intp)
