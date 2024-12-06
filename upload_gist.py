import os
import requests

GIST_ID = os.getenv('GIST_ID')
GIST_API_URL = f'https://re-gist.dsdog.tk/gists/{GIST_ID}'
GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')

# 读取要上传的文件
config_file_path = 'clash_config.yaml'

# 上传到 Gist
def upload_gist():
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
    
    response = requests.patch(GIST_API_URL, json=gist_data, headers=headers)
    if response.status_code == 200:
        print('Gist updated successfully:', response.json()['html_url'])
    else:
        print('Failed to update Gist:', response.text)

# 运行上传
if __name__ == '__main__':
    upload_gist()