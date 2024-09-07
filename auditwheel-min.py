import sys

import unittest.mock
from auditwheel.policy import WheelPolicies
from auditwheel.lddtree import lddtree

ldd_tree = lddtree('_skbuild/linux-x86_64-3.11/cmake-install/cv2/cv2.abi3.so')
exclude_libs = [x for x in ldd_tree['libs'].keys() if not x.startswith('libopencv_')]

class _WheelPolicies(WheelPolicies):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for p in self._policies:
            for lib in exclude_libs:
                p['lib_whitelist'].append(lib)

if __name__ == "__main__":
    with unittest.mock.patch('auditwheel.policy.WheelPolicies', _WheelPolicies):
        from auditwheel.main import main
        sys.exit(main())
