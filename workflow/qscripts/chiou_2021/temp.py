import re
def match_multiple_regexes(s, regexes):
    
    if type(regexes) != list:
        regexes = [regexes]
        
    for regex in regexes:
        if regex.match(s):
            return(True)
    return(False)      

def extract_cols_with_prefixes(cols, prefixes=None):
    
    if type(prefixes) != list:
        prefixes = [prefixes]
    
    regexes = []
    for prefix in prefixes: 
        regex = re.compile('^{}'.format(prefix))
        regexes.append(regex)

    rcols = []
    for col in cols: 
        if match_multiple_regexes(col, regexes):
            rcols.append(col)
    return(rcols)
