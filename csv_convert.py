import pandas as pd
import csv
import re


txt_file_path = 'data/test_data01.txt'
csv_path = 'data/zku_OpenHausData_noTime.csv'
csv_file = 'data/zku_OpenHausData.csv'
#df = pd.read_csv(csv_file, sep=';', thousands='.', decimal=',')
df = pd.read_csv(csv_file, sep=';')
df_columns = list(df.columns.values)[1:]
print("df columns has {} names from {} ..... {}".format(len(df_columns), df_columns[0:2], df_columns[-2:]))
no_brackets = []
for x in list(df.columns.values):
    #print("old name {}".format(x))
    new_name = re.sub("([\(\[]).*?([\)\]])", "", x)
    new_name = new_name.replace(" ", "_")
    #print("new name  {}".format(new_name))
    no_brackets.append(new_name)

df.columns = no_brackets
no_time = no_brackets[1:]
print("no_time has {} names from {} ..... {}".format(len(no_time), no_time[0:2], no_time[-2:]))
df.to_csv(csv_path, columns=no_time)

def convert_csv(t_path, c_path):
    read_file = pd.read_csv(t_path)
    read_file.to_csv(c_path)

def csv_convert():
    with open(txt_file_path, 'r') as in_file:
        stripped = (line.strip().replace("\\", "") for line in in_file)
        lines = (line.split(",") for line in stripped if line)
        with open(csv_path, 'w') as out_file:
            writer = csv.writer(out_file)
            writer.writerows(lines)

#csv_convert()
#check if values are floats
# for v in df.values:
#     for e in v:
#         print("is this {} a float? {}  ".format(e, isinstance(e, float)))

