# Tables required from Oracle DB

## For Geographies

village.csv from M_VILLAGE

panchayat.csv from M_PANCHAYAT

block.csv from M_BLOCK

district.csv from M_DISTRICT

districtmapping.csv from MP_DISTRICT_SCHEME


## For Masters

member3.csv from MP_CBO_MEMBER (subsetted import via <br> select CBO_ID, MEMBER_ID, DESIGNATION_ID from MP_CBO_MEMBER)

cbo.csv from M_CBO (subsetted import via <br> select DISTRICT_ID , BLOCK_ID, VILLAGE_ID, CBO_ID, CBO_NAME, FORMATION_DATE,  CBO_TYPE_ID , CREATED_BY , CREATED_ON, UPDATED_BY, UPDATED_ON, REGISTRATION_NUMBER, REGISTRATION_DATE, RECORD_STATUS from M_CBO)

cbo mapping.csv from MP_PARENT_CBO

ac_master.csv from T_CBO_APPL_MAPPING (subsetted import via <br> select CBO_ID, ACC_OPENING_STATUS from T_CBO_APPL_MAPPING)

## For Transactions

avoucher.csv from T_ADJUSTMENT_VOUCHER

voucher master.csv from T_ACC_VOUCHER

transactions.csv from T_VOUCHER_LEDGER

loan detail.csv from T_CBO_LOAN_REGISTER

repayment.csv from MP_LOAN_REPAYMENT


