import { readFileSync, writeFileSync, rmSync } from 'fs';
import { DOMParser, XMLSerializer } from '@xmldom/xmldom';

const packageJson = JSON.parse(readFileSync('package.json', 'utf8'));
packageJson.version += '-slim';
writeFileSync('package.json', JSON.stringify(packageJson, undefined, '  ') + '\n');
const version = packageJson.version;

const doc = new DOMParser().parseFromString(readFileSync('plugin.xml', 'utf-8'), 'text/xml');
const pluginXml = doc.documentElement;
pluginXml.setAttribute('version', version);
console.log('Changed plugin.xml version to ', pluginXml.getAttribute('version'));

const configFileEls = pluginXml.getElementsByTagName('config-file');
for (const configFileEl of Array.from(configFileEls)) {
    if (configFileEl.getAttribute('target') == 'AndroidManifest.xml') {
        configFileEl.parentNode.removeChild(configFileEl);
        break;
    }
}
console.log('Removed plugin.xml config-file[target=AndroidManifest] node');

for (const hookEl of Array.from(pluginXml.getElementsByTagName('hook'))) {
    hookEl.parentNode.removeChild(hookEl);
}
console.log('Removed plugin.xml hook');
writeFileSync('plugin.xml', new XMLSerializer().serializeToString(doc));

rmSync('hooks', { recursive: true, force: true });
console.log('Removed hooks folder');

rmSync('stripDuplicatePermissions.js', { force: true });
console.log('Removed stripDuplicatePermissions hook');
