import requests
import json
import glob
import timeit

ENDPOINT = 'https://api.avax.network/ext/bc/C/rpc'


def fill_template(market, idx):
    market = market.removeprefix('0x').zfill(64)
    return {"jsonrpc":"2.0", "id": idx, "method": "eth_call", "params": [{"from": "0x5c4100f70ECE929953a408A600e43cf866703280", "to": '0x465f9B8A10629F3AA8751496162298c05489F5ca', "data": "0x1df49883%s"%market}, "latest"]}


def batch_diligence(addresses):
    data = [fill_template(a, i) for i, a in enumerate(addresses)]
    headers = {'content-type': 'application/json'}
    r = requests.post(ENDPOINT, headers=headers, data=json.dumps(data))
    js = r.json()
    try:
        results = map(lambda x: 7 if 'error' in x else int(x['result'], 16), js)
        return {a: result for result, a in zip(results, addresses)}
    except:
        for jsi in js:
            print(jsi)
        raise


def main():
    expected = {
      "0x53b72776f8402C1F3dAFa228895fD49eF18768eF": 0,
      "0xD1a3F2AE385dc33515ea3a1c69435c0931B81a54": 1,
      "0x5ca45BdD971187e2019773cc34C62111e87007C6": 2,
      "0xC6694c70Ce377dE86c283B9814812151D6d12814": 3,
      "0xC9BbCF1683CB6B04db8D941F460C7667Dda9b7da": 4,
      "0x5dfC3e16F4d29bA877b5Ef9CF40fc0e4C1468710": 5,
      "0xf31c53F59ece33a11636552B8355263bc543a2f1": 7,
    }
    market_addresses = list(expected.keys())
    diligence = batch_diligence(market_addresses)
    for m in market_addresses:
        assert(expected[m] == diligence[m])
        print(m, diligence[m])


if __name__ == '__main__':
    main()
