#!/usr/bin/env python3
import argparse
import logging
import requests

def search_versions(versions, chrome_version, exact=True):
    for version in versions:
        if exact and version['version'] == chrome_version:
            return version
        if not exact and version['version'].startswith(f'{chrome_version}.'):
            return version
    return None

def search_binary_by_platform(downloads, platform):
    for download in downloads:
        if download['platform'] == platform:
            return download
    return None

argparser = argparse.ArgumentParser()
argparser.add_argument('--chrome-version', required=True,
                       help='Chrome version to resolve ChromeDriver version for')
argparser.add_argument('--platform', required=True, help='Platform for ChromeDriver binary')
argparser.add_argument('--debug', action='store_true', help='Print debug information')

args = argparser.parse_args()

if args.debug:
    logging.basicConfig(level=logging.DEBUG)

# convenient JSON endpoints for specific ChromeDriver version downloading
# https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json
resp = requests.get('https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json')
versions = resp.json()['versions']
target_version = search_versions(versions, args.chrome_version)
chrome_version = args.chrome_version
while not target_version and '.' in chrome_version:
    chrome_version = '.'.join(chrome_version.split('.')[:-1])
    target_version = search_versions(versions, chrome_version, exact=False)
if not target_version:
    print(f'Could not find ChromeDriver version for Chrome version {args.chrome_version}')
    exit(1)
logging.debug(f'Downloads(for {chrome_version}): {target_version}')
binary = search_binary_by_platform(target_version['downloads']['chromedriver'], args.platform)
if not binary:
    print(f'Could not find ChromeDriver binary for platform {args.platform}')
    exit(1)
print(binary['url'])