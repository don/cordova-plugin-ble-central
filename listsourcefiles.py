
import os
from posixpath import relpath
template = '<source-file src="{{FILE_PATH}}" target-dir="src/com/megster/cordova/ble/central/{{ADITIONAL_PATH}}" />'
androidPath = os.path.join('src', 'android')
pathToTravel = os.path.join(os.path.dirname(os.path.realpath(__file__)), androidPath)
# Walk through the directory tree and find all files recursively
for root, dirs, files in os.walk(pathToTravel):
    for file in files:
        if file.endswith('.java'):
            relPath = os.path.relpath(os.path.join(root, file), os.path.dirname(os.path.realpath(__file__)))
            relDir = os.path.dirname(os.path.relpath(relPath, androidPath))
            sourceFile = template.replace('{{FILE_PATH}}', os.path.join(relPath))
            sourceFile = sourceFile.replace('{{ADITIONAL_PATH}}',os.path.join('',relDir))
            sourceFile = sourceFile.replace('\\', '/')
            print(sourceFile)
