from distutils.core import setup
from distutils.extension import Extension

# Test if Cython is available
try:
    from Cython.Distutils import build_ext
    USE_CYTHON = True
except ImportError:
    USE_CYTHON = False

"""
Normally we should do something like this:

import numpy as np
np_include = np.get_include()

but compiling with python-for-android results in 64 vs. 32 bit python.host
errors, here is a hack:
"""
import os.path
import site
np_include = os.path.join(site.getsitepackages()[0], 'numpy/core/include')

ext = '.pyx' if USE_CYTHON else '.c'
extensions = [Extension('cimutils._draw',
                        sources=['cimutils/_draw' + ext],
                        include_dirs=[np_include]),

              Extension('cimutils._shared',
                        sources=['cimutils/_shared' + ext]),

              Extension('cimutils._ccomp', sources=['cimutils/_ccomp' + ext],
                        include_dirs=[np_include])
              ]

# Select Extension
if USE_CYTHON:
    from Cython.Build import cythonize
    extensions = cythonize(extensions)

setup(name="cimutils",
      version='1.0',
      packages=['cimutils'],
      package_dir={'cimutils': 'cimutils'},
      package_data={'cimutils': ['cimutils/*.pxd']},
      ext_modules=extensions
      )
