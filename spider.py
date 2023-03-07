import asyncio
import aiohttp

import re
import os
import json

import SilenceEventLoopClosed


async def getText(session, url):
    print("请求url:", url)
    timeout = aiohttp.ClientTimeout(5)
    async with session.get(url, verify_ssl=False, headers=h, proxy=p['http'], timeout=timeout) as res:
        ts = await res.text(encoding=res.charset if res.charset is not None else 'utf8')
        return ts


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

        with open(f'ou.json', 'w', encoding='utf8') as w:
            w.write(jsonStr)
        
        urlsDic = json.loads(jsonStr)
        urlDicList = urlsDic['urls']

        tasks = [
            asyncio.create_task(config2File(s, urlDic['url'], urlDic['name'], index)) for index,urlDic in enumerate(urlDicList)
        ]

        await asyncio.wait(tasks)

        with open(f'source.json', 'w', encoding='utf8') as w:
            w.write(json.dumps(myUrlDic, ensure_ascii=False))


def parseResult(result):
    l = []
    resultList = list(result)
    for resultSet in resultList:
        resultJsonStr = resultSet.result()
        # 正则处理json中的注释
        resultJsonStr = reJsonString(resultJsonStr)
        l.append(json.loads(resultJsonStr))
    return l


async def config2File(s, u, n, i):
    global myUrlDic
    try:
        jsonStr = await getText(s, u)
        with open(f'boxCfg/{i}.json', 'w', encoding='utf8') as w:
            w.write(jsonStr)
        print(u, n)
        myUrlDic['urls'].append({'name': n, 'url': f'https://raw.iqiq.io/mlabalabala/TVResource/main/boxCfg/{i}.json'})
    # jsonStr = reJsonString(jsonStr)
    except Exception:
        print(u, ' ------> error')
        


def reJsonString(jsonStr):
    return re.sub(r'([^:]//.*\"?$)','',jsonStr, 0, re.MULTILINE)



if __name__ == '__main__':

    h = {
        "User-Agent": "okhttp/3.15",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
    }

    p = {"http": None, "https": None}
    # p = {"http": "http://127.0.0.1:10809"}

    curPath = os.path.dirname(__file__)
    myUrlDic = {}
    myUrlDic['urls'] = []

    

    # asyncio.run(getStoreHouse('https://raw.iqiq.io/mlabalabala/TVResource/main/storeHouse.json'))
    asyncio.run(getStoreHouse('http://tv.nxog.top/api.php?mz=xb&id=2&b=派大星'))
