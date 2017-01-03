#cython: cdivision=True
#cython: boundscheck=False
#cython: nonecheck=False
#cython: wraparound=False


cdef inline unsigned char point_in_polygon(Py_ssize_t nr_verts, double *xp,
                                           double *yp, double x,
                                           double y) nogil:
    """Test whether point lies inside a polygon.

    Parameters
    ----------
    nr_verts : int
        Number of vertices of polygon.
    xp, yp : double array
        Coordinates of polygon with length nr_verts.
    x, y : double
        Coordinates of point.
    """
    cdef Py_ssize_t i
    cdef unsigned char c = 0
    cdef Py_ssize_t j = nr_verts - 1
    for i in range(nr_verts):
        if (
            (((yp[i] <= y) and (y < yp[j])) or
            ((yp[j] <= y) and (y < yp[i])))
            and (x < (xp[j] - xp[i]) * (y - yp[i]) / (yp[j] - yp[i]) + xp[i])
        ):
            c = not c
        j = i
    return c
