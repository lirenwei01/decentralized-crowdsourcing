import xlrd;
workbook = xlrd.open_workbook(r'C:\Users\DELL\Desktop\blokhashs2.xls')
sheet1 = workbook.sheet_by_index(0)
import numpy
import sha3
import random
total = numpy.zeros(100)
no6 = numpy.zeros(100)
no0 = numpy.zeros(100)
rate0 = numpy.zeros(100)
rate6 = numpy.zeros(100)
for i in range(0,50000):
    seed1 = 0
    for j in range(0,12):
        seed1 += int(sheet1.cell(i+j,0).value)
    seed = seed1
    chonum = 0;
    chosen = numpy.zeros(100)
    while chonum < 10:
        
        cho = seed%100
        if(chosen[cho]==0):
            chosen[cho] = 1
            total[cho] += 1
            chonum+=1
        seed = hash(random.randint(0,seed1))
    sum = 0
    l = 0
    flag = 0
    while sum < 6:
        sum+=chosen[l]
        if(sum == 1 and flag ==0):
            no0[l]+=1
            flag = 1
        if(sum == 6):
            no6[l]+=1
        l += 1


for i in range(0,100):
    k = 0
    for j in range(0,1+i):
        k += no0[j]
    rate0[i] = k/500;

for i in range(0,100):
    k = 0
    for j in range(0,1+i):
        k += no6[j]
    rate6[i] = k/500;



# for i in range(0,60):
#     print(rate6[i],end = ',')


print(rate0)
