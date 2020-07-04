from distutils.core import setup, Extension


module = Extension(
    '_mp3lame',
    sources=['mp3lame.i'],
    libraries=['mp3lame']
)


setup(
    name='mp3lame',
    version='1.0',
    ext_modules=[module]
)
