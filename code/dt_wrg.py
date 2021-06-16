#libraries
import os
from pathlib import Path
import pandas as pd
root = Path('data', '4. Mediciones Velocidades', '1. Mediciones recorrido electro corredor')
fl = os.listdir(root)
#ec1 = pd.read_csv(root/'Ida_8_6_2021_12_31_2021-06-08_12-31-03.csv', sep=',', skiprows= 15)
#input
lst = []
for fn in fl:
    df = pd.read_csv(root/fn, sep=',', skiprows= 15, index_col=None, header=0)
    df['filename'] = os.path.basename(fn)
    lst.append(df)
df_bnd = pd.concat(lst, axis=0, ignore_index=True)
df_bnd