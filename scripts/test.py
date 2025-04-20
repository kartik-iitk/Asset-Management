import pandas as pd

def format_value(val):
    if pd.isna(val):
        return 'NULL'
    if isinstance(val, str):
        # wrap strings in single quotes, escape any single-quote by doubling it
        return "'" + val.replace("'", "''") + "'"
    if isinstance(val, pd.Timestamp):
        return "'" + val.strftime('%Y-%m-%d %H:%M:%S') + "'"
    return str(val)

def sheet_to_inserts(sheet_name, df):
    inserts = []
    cols = list(df.columns)
    col_list = ', '.join(cols)
    for _, row in df.iterrows():
        vals = ', '.join(format_value(row[col]) for col in cols)
        inserts.append(f"INSERT INTO {sheet_name} ({col_list}) VALUES ({vals});")
    return inserts

def main():
    excel_file = 'Sample Data 1.xlsx'
    output_sql = 'insert_sample_data.sql'
    
    xls = pd.ExcelFile(excel_file)
    all_inserts = []
    for sheet in xls.sheet_names:
        df = pd.read_excel(xls, sheet_name=sheet)
        if df.empty:
            continue
        all_inserts.append(f"-- Inserts for table `{sheet}`")
        all_inserts += sheet_to_inserts(sheet, df)
        all_inserts.append('')  # blank line
    
    with open(output_sql, 'w', encoding='utf-8') as f:
        f.write('\n'.join(all_inserts))
    print(f"Generated {output_sql} with inserts for sheets: {', '.join(xls.sheet_names)}")

if __name__ == '__main__':
    main()