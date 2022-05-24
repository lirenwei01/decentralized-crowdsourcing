import requests
import json
import jsonpath
import sha3
import xlwt
import xlrd

def get_ethHash(number):
    #url地址
    url = 'https://api.yitaifang.com/index/header/?number={}'.format(number)

    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.54 Safari/537.36'
    }

    response = requests.get(url=url, headers=headers)
    content = response.text

    with open('902ethhash.json', 'w', encoding='utf-8') as fp:
        fp.write(content)

    #使用jsonpath进行分析
    infoJson = json.load(open('902ethhash.json', 'r', encoding='utf-8'))

    ethHash = jsonpath.jsonpath(infoJson, '$.data.hash')[0]
    number = jsonpath.jsonpath(infoJson, '$.data.number')[0]
    #print("number: "+ str(number) + "，ethHash："  + str(ethHash))
    return(str(int(ethHash,0)))

if __name__ == "__main__":
    up = 14650100
    low = 14600000
    book = xlwt.Workbook(encoding = 'utf-8')
    sheet1 = book.add_sheet('Sheet1',cell_overwrite_ok = True)
    for number in range(low, up):
        sheet1.write(number - 14600000,0,get_ethHash(number))
    book.save(r'C:\Users\DELL\Desktop\blokhashs2.xls')
