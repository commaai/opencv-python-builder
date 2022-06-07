import os
import sys

from auditwheel.main import main
from auditwheel.policy import _POLICIES as POLICIES
from auditwheel.lddtree import lddtree

ldd_tree = lddtree('_skbuild/linux-x86_64-3.8/cmake-install/cv2/cv2.abi3.so')
exclude_libs = [x for x in ldd_tree['libs'].keys() if not x.startswith('libopencv_')]

for p in POLICIES:
    for lib in exclude_libs:
        p['lib_whitelist'].append(lib)

if __name__ == "__main__":
    sys.exit(main())
