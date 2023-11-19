
import xmldom from 'xmldom';
import builder from 'xmlbuilder';

export default {
  /*
  `parse(xml, [property])`
  
  Parse an xml document and retrieve one or multiple properties.
  
  Retrieve all properties: `properties = parse(xml)`
  Retrieve a single property: `value = parse(xml, property)`
  */
  parse: function(markup, property) {
    const properties = {};
    const doc = new xmldom.DOMParser().parseFromString(markup);
    for (const i in doc.documentElement.childNodes) {
      const propertyChild = doc.documentElement.childNodes[i]
      if (propertyChild.tagName?.toUpperCase() !== 'PROPERTY') {
        continue;
      }
      let name, value;
      for (const j in propertyChild.childNodes) {
        const child = propertyChild.childNodes[j];
        if (child.tagName?.toUpperCase() === 'NAME') {
          name = child.childNodes[0].nodeValue;
        }
        if (child.tagName?.toUpperCase() === 'VALUE') {
          value = child.childNodes[0].nodeValue || '';
        }
      }
      if (property && name === property && value != null) {
        return value;
      }
      if (name && (value != null)) {
        properties[name] = value;
      }
    }
    return properties;
  },
  /*
  `stringify(properties)`
  
  Convert a property object into a valid Hadoop XML markup. Properties are
  ordered by name.
  
  Convert an object into a string:
  
  ```
  markup = stringify({
    'fs.defaultFS': 'hdfs://namenode:8020'
  });
  ```
  
  Convert an array into a string:
  
  ```
  stringify([{
    name: 'fs.defaultFS', value: 'hdfs://namenode:8020'
  }])
  ```
  */
  stringify: function(properties) {
    const markup = builder.create('configuration', {
      version: '1.0',
      encoding: 'UTF-8'
    });
    if (Array.isArray(properties)) {
      properties.sort(function(el1, el2) {
        return el1.name > el2.name;
      });
      for (const {name, value} of properties) {
        const property = markup.ele('property');
        property.ele('name', name);
        property.ele('value', value);
      }
    } else {
      const ks = Object.keys(properties).sort();
      for (const k of ks) {
        const property = markup.ele('property');
        property.ele('name', k);
        property.ele('value', properties[k]);
      }
    }
    return markup.end({
      pretty: true
    });
  },
}
