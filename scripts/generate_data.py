import pandas as pd
from faker import Faker
from random import choice, randint, random
from datetime import datetime, timedelta

fake = Faker()

def make_roles():
    roles = ['Admin','HOD','Lab Incharge','Lab Assistant','Student']
    return [{
        'RoleName': r,
        'RoleDesc': f"{r} role",
        'DateCreated': datetime.now(),
        'IsActive': True
    } for r in roles]

def make_users(n=20):
    rows = []
    for _ in range(n):
        dob = fake.date_of_birth(minimum_age=18, maximum_age=60)
        rows.append({
            'UserName': fake.user_name(),
            'UserPassword': 'P@ssw0rd',
            'InstituteId': fake.bothify('IITK###'),
            'FirstName': fake.first_name(),
            'MiddleName': fake.first_name(),
            'LastName': fake.last_name(),
            'Gender': choice(['Male','Female','Other']),
            'DOB': dob,
            'Email': fake.email(),
            'Contact': fake.phone_number(),
            'UserAddress': fake.address().replace('\n',' '),
            'IsAppUser': choice([True, False]),
            'DateCreated': datetime.now(),
            'IsActive': True
        })
    return rows

def make_departments():
    names = ['Physics','Chemistry','Biology','Computer Science']
    return [{
        'DeptName': d,
        'DeptDesc': f"{d} Dept",
        'DateCreated': datetime.now(),
        'IsActive': True
    } for d in names]

def make_labs(dept_ids, n=6):
    rows = []
    for _ in range(n):
        rows.append({
            'DeptId': choice(dept_ids),
            'LabName': fake.word().title() + ' Lab',
            'FundsAvailable': round(randint(10000,50000) + random(), 2),
            'DateCreated': datetime.now(),
            'IsActive': True
        })
    return rows

def make_items(user_ids, n=10):
    cats = ['Monitor','Keyboard','CPU','Camera','Motor']
    rows = []
    for _ in range(n):
        rows.append({
            'Category': choice(cats),
            'Make': fake.company(),
            'Model': fake.bothify('M-##??'),
            'WarrantyPeriodMonths': choice([6,12,24,36]),
            'ItemDescription': fake.sentence(nb_words=5),
            'CreatedBy': choice(user_ids),
            'DateCreated': datetime.now(),
            'IsActive': True
        })
    return rows

def main():
    # 1) Roles
    df_roles = pd.DataFrame(make_roles())

    # 2) Users
    df_users = pd.DataFrame(make_users(25))

    # 3) Department
    df_dept = pd.DataFrame(make_departments())

    # We need dept and user PKs for relational sheets
    # Here we fake them starting at 1 in order inserted
    dept_ids = list(range(1, len(df_dept)+1))
    user_ids = list(range(1, len(df_users)+1))

    # 4) Lab
    df_lab = pd.DataFrame(make_labs(dept_ids, 6))
    lab_ids = list(range(1, len(df_lab)+1))

    # 5) UserRole
    ur = []
    role_count = len(df_roles)
    for _ in range(12):
        ur.append({
            'UserId': choice(user_ids),
            'DeptID': choice(dept_ids),
            'LabId': choice(lab_ids),
            'RoleId': randint(1, role_count),
            'DateJoined': datetime.now() - timedelta(days=randint(1,200)),
            'DateLeft': None,
            'DateCreated': datetime.now(),
            'IsActive': True
        })
    df_userrole = pd.DataFrame(ur)

    # 6) Item
    df_item = pd.DataFrame(make_items(user_ids, 15))
    item_ids = list(range(1, len(df_item)+1))

    # 7) LabActivity
    la = []
    for _ in range(8):
        alloc = round(randint(2000,10000) + random(), 2)
        la.append({
            'LabId': choice(lab_ids),
            'InitiatorId': choice(user_ids),
            'ActivityType': choice(['Research','Project','Maintenance']),
            'ActivityDescription': fake.sentence(nb_words=4),
            'FundsAllocated': alloc,
            'FundsAvailable': alloc,
            'StartDate': datetime.now() - timedelta(days=randint(0,30)),
            'EndDate': None,
            'IsClosed': False,
            'DateCreated': datetime.now()
        })
    df_labact = pd.DataFrame(la)
    act_ids = list(range(1, len(df_labact)+1))

    # 8) Simple empty logs & per‐table you can add rows similarly…

    # 9) Export all to Excel
    sheets = {
        'Roles': df_roles,
        'Users': df_users,
        'Department': df_dept,
        'Lab': df_lab,
        'UserRole': df_userrole,
        'Item': df_item,
        'LabActivity': df_labact,
        # add other DataFrames here as needed...
    }

    with pd.ExcelWriter('Sample Data 1.xlsx', engine='openpyxl') as writer:
        for name, df in sheets.items():
            df.to_excel(writer, sheet_name=name, index=False)

    print("✅ Generated Sample Data 1.xlsx")

if __name__ == '__main__':
    main()