import os
import pandas as pd
import numpy as np

# -------------------------------------------------
# 1. path
# -------------------------------------------------
os.chdir(os.path.dirname(os.path.abspath(__file__)))

path       = r'data_cleaned.xlsx'                 
save_path  = r'result_with_EI.xlsx'       

# -------------------------------------------------
# 2. read Excel data
# -------------------------------------------------
df = pd.read_excel(path, engine='openpyxl')


# 2.2  Keep data if only Year >= birth_fixed
before_len = len(df)
df = df[df['Year'] >= df['birth_fixed']]
after_len = len(df)

# 2.3 Calculate age_it
df['age_it'] = df['Year'] - df['birth_fixed']
df['age_it'] = df['age_it'].astype(int)

df['CCPI'] = pd.to_numeric(df['CCPI'], errors='coerce')
df['panelid'] = df['panelid'].astype(str)

# -------------------------------------------------
# 3. Calculate experienced inflation
# -------------------------------------------------
def calc_experienced_inflation(df, lambda_: float = 11.03):
    df = df.sort_values(['panelid', 'Year']).reset_index(drop=True)
    df['Experienced_inflation'] = np.nan
    

    for pid, panel in df.groupby('panelid', sort=False):
        age = panel['age_it'].values
        cpi = panel['CCPI'].values
        n   = len(panel)
        E   = np.full(n, np.nan)

        for i in range(n):
            # If age < 1, skip
            if age[i] <= 1:
                continue

            sum_w = sum_inf = 0.0
            max_k = int(age[i] - 1)
            
        
            for k in range(1, max_k + 1):
                j = i - k
                
                if j < 0:
                    continue
                
                if np.isnan(cpi[j]):
                    continue
                
                w = (age[i] - k) ** lambda_
                sum_w   += w
                sum_inf += w * cpi[j]

            if sum_w > 0:
                E[i] = sum_inf / sum_w

        df.loc[panel.index, 'Experienced_inflation'] = E
    return df

df = calc_experienced_inflation(df)

# -------------------------------------------------
# 4. Save the result
# -------------------------------------------------
df.to_excel(save_path, index=False, engine='openpyxl')
print("Clear")