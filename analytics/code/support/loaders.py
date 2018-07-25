import os
ROOT = os.path.expanduser('~') + '/Dropbox/Projects/BIGSSS/Data/GTD/'

def load_gtd():
    '''
    Loads the entire Global Terrorism Database excel file set
    '''
    import pandas as pd
    import glob
    #the globalterrorismdb_0615dist.xlsx seems to be a concatenation of all the gtd_*.xlsx files
    dfset = [pd.read_excel(fname, sheet=0) \
             for fname in glob.glob(ROOT + 'gtd_*_0615dist.xlsx')]
    df = pd.concat(dfset)
    return df
