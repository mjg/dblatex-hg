import sys
import StringIO
import codecs
import os

base = os.path.dirname(os.path.abspath(os.path.join(__file__, "../../..")))

sys.path.append(base)

from codec import XetexCodec
from fsencoder import FontSpecEncoder


conf = '''
<fonts>
  <fontspec default="1" id="default">
    <enter>
      <font type="main">EnterAMain</font>
    </enter>
    <!--
    <inter>
      <font type="main">InterAMain</font>
      <font type="sans">InterASans</font>
    </inter>
    -->
    <exit>
      <font type="sans">ExitASans</font>
    </exit>
  </fontspec>
  <fontspec range="U04EAC-U09CB8" id="special">
    <enter>
      <font type="main">EnterMSpecial</font>
    </enter>
    <exit>
      <font type="main">ExitMSpecial</font>
      <font type="sans">ExitSSpecial</font>
    </exit>
  </fontspec>
</fonts>
'''

encoder = FontSpecEncoder(StringIO.StringIO(conf))
sys.stdout = codecs.lookup('utf-8')[-1](sys.stdout)
input = u'aei#\\\u4EAC{\\}_uuu\u4EAC'

c = XetexCodec(StringIO.StringIO(conf))
s = c.encode(input)
print s.decode("utf8")
