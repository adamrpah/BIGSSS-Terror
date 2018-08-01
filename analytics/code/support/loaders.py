import os
ROOT = os.path.expanduser('~') + '/Dropbox/Projects/BIGSSS/Data/GTD/'

def load_gtd(index_col=0):
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

def load_country_data(fname, start=2001, end=2005, index_col=0):
    '''
    Loads and cleans a country csv cut
    '''
    def datetimer(x):
        try:
            return datetime.strptime(x, '%m-%d-%Y')
        except:
            parts = x.split('-')
            return datetime.strptime('-'.join([parts[0], str(int(parts[1])+1), parts[2]]), '%m-%d-%Y')

    def clean_names(x, final_name, input_names):
        if x in input_names:
            return final_name
        else:
            return x

    import pandas as pd
    from datetime import datetime
    #Load the dataframe
    tdf = pd.read_csv(fname, index_col=index_col)
    #Group name handler
    tdf['gname'] = tdf['gname'].apply(lambda x: clean_names(x, 'AQI', ['Tawhid and Jihad', 'Al-Qa`ida in Iraq']))
    tdf['gname'] = tdf['gname'].apply(lambda x: clean_names(x, 'Al-Qaeda', ['Al-Qa`ida']))
    tdf['gname'] = tdf['gname'].apply(lambda x: clean_names(x, 'United Self Defense Units of Colombia (AUC)', ['Death Squad', 'Right-Wing Death Squad', 'Right-Wing Paramilitaries', 'Paramilitaries']))
    tdf['gname'] = tdf['gname'].apply(lambda x: clean_names(x, 'Taliban', ['Islamic Movement of Uzbekistan (IMU)']))
    #Create the string date
    tdf['strdate'] = tdf.apply(lambda x: str(x['imonth']) + '-' + str(x['iday']) + '-' + str(x['iyear']), axis=1)
    #Conver the dates with datetime
    tdf['datetime'] = tdf.strdate.apply(datetimer)
    tdf['date'] = pd.to_datetime(tdf['datetime'])
    tdf.sort_values('date', inplace=True)
    return tdf
