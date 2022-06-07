# Make sure we didn't include any libraries except libopencv                                              
import sys
import zipfile

prefix = 'opencv_python.libs/'
assert len (sys.argv) > 1
for fn in sys.argv[1:]:
  print(f'verifying libraries for {fn}...')
  whl = zipfile.ZipFile(fn)
  libs = [x[len(prefix):] for x in whl.namelist() if x.startswith(prefix) and x != prefix]
  assert len(libs) > 0
  for lib in libs:
    assert lib.startswith('libopencv_'), f'shared library {lib} should not be bundled with this wheel!'
  print('success!')
