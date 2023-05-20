import { readFileSync, writeFileSync } from 'fs';
import { DOMParser, XMLSerializer } from '@xmldom/xmldom';

const { version } = JSON.parse(readFileSync('package.json', 'utf8'));

const doc = new DOMParser().parseFromString(readFileSync('plugin.xml', 'utf-8'), 'text/xml');
const pluginXml = doc.documentElement;
pluginXml.setAttribute('version', version);
writeFileSync('plugin.xml', new XMLSerializer().serializeToString(doc));

console.log('Changed plugin.xml version to ', pluginXml.getAttribute('version'));
