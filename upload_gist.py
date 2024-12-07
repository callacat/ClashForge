import os
import requests
import time

GIST_ID = os.getenv('GIST_ID')
GIST_API_URL = f'https://re-ghapi.dsdog.tk/gists/{GIST_ID}'
GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
# 读取要上传的文件
config_file_path = 'clash_config.yaml'

# 上传到 Gist，增加重试机制
def upload_gist(max_retries=3, retry_delay=5):
    with open(config_file_path, 'r') as file:
        content = file.read()

    # 要更新的 Gist 数据
    gist_data = {
        'files': {
            'clash_config.yaml': {
                'content': content
            }
        }
    }

    headers = {
        'Authorization': f'token {GITHUB_TOKEN}',
        'Accept': 'application/vnd.github.v3+json'
    }

    for attempt in range(max_retries):
        try:
            response = requests.patch(GIST_API_URL, json=gist_data, headers=headers)
            response.raise_for_status()  # 如果响应状态码不是 2xx，抛出 HTTPError 异常

            print('Gist updated successfully:', response.json()['html_url'])
            return  # 上传成功，退出函数

        except requests.exceptions.RequestException as e:
            print(f"Attempt {attempt + 1} failed: {e}")
            if attempt < max_retries - 1:
                print(f"Retrying in {retry_delay} seconds...")
                time.sleep(retry_delay)
            else:
                print(f"Failed to update Gist after {max_retries} attempts.")

# 运行上传
if __name__ == '__main__':
    upload_gist()