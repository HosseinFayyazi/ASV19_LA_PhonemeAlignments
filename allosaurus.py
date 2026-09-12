# pip install allosaurus
from allosaurus.app import read_recognizer

# load your model
model = read_recognizer()
res = model.recognize('wav/LA_T_1000137.wav', lang_id='eng', emit=1, timestamp=True)
print(res)
