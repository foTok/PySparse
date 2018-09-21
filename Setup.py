#!/usr/bin/python
#python version: 
#Filename: 
 
# Run as:  
#    python Setup.py build_ext --inplace  
   
import sys  
sys.path.insert(0, "..")  
   
from distutils.core import setup  
from distutils.extension import Extension  
from Cython.Build import cythonize  
from Cython.Distutils import build_ext
   
ext_module = Extension("PySparse",
                    ["pycsparse.pyx"],
                    extra_compile_args=["/openmp"],
                    extra_link_args=["/openmp"],
                    libraries=['CSparse'],
                    library_dirs=['./CSparse/lib/Release/32']
            )
   
setup(
    cmdclass = {'build_ext': build_ext},
        ext_modules = [ext_module], 
)

