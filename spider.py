import asyncio
from email import header
from time import sleep
from urllib import request
from weakref import proxy
import aiohttp

import re
import os
import json


async def getText(session, url):
    print("请求url:", url)
    async with session.get(url, verify_ssl=False, headers=h, proxy=p['http']) as res:
        ts = await res.text(encoding=res.charset if res.charset is not None else 'utf8')
        return ts


async def main():
    async with aiohttp.ClientSession() as session:
        pass

    pass


async def getStoreHouse(url):
    async with aiohttp.ClientSession() as s:
        jsonStr = await getText(session=s, url=url)

        # async with open(curPath + '/storeHouse', 'w', encoding='utf8') as w:
        #     w.write(jsonStr)
        
        storeHouseDic = json.loads(jsonStr)

        # 多仓
        # tasks = [
        #     asyncio.create_task(getText(s, source['sourceUrl'])) for source in storeHouseDic['storeHouse']
        # ]
        # result, padding = await asyncio.wait(tasks)
        # urlsDicList = parseResult(result)
        # print(urlsDicList)

        # 单仓
        sourceUrl = storeHouseDic['storeHouse'][0]['sourceUrl']
        jsonStr = await getText(session=s, url=sourceUrl)
        urlsDic = json.loads(jsonStr)
        urlDicList = urlsDic['urls']


def parseResult(result):
    l = []
    resultList = list(result)
    for resultSet in resultList:
        resultJsonStr = resultSet.result()
        # 正则处理json中的注释
        resultJsonStr = re.sub(r'([^:]//.*\"?$)','',resultJsonStr, 0, re.MULTILINE)
        l.append(json.loads(resultJsonStr))
    return l


if __name__ == '__main__':

    h = {
        "User-Agent": "okhttp/3.15",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
    }

    p = {"http": None, "https": None}

    curPath = os.path.dirname(__file__)

    asyncio.run(getStoreHouse('http://tv.nxog.top/api.php?mz=xb&id=2&b=派大星'))
