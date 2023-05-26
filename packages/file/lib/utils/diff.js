/*

# Diff

Report the difference between 2 strings.

*/

// ## Dependencies
const pad = require('pad');
const diff = require('diff');
const string = require('@nikitajs/core/lib/utils/string');

// Utils
module.exports = function(oldStr, newStr) {
  if (oldStr == null) {
    oldStr = '';
  }
  if (newStr == null) {
    newStr = '';
  }
  const lines = diff.diffLines(oldStr, newStr);
  let text = [];
  let count_added = count_removed = 0;
  const padsize = Math.ceil(lines.length / 10);
  for (const line of lines) {
    if (line.value === null) {
      continue;
    }
    if (!line.added && !line.removed) {
      count_added++;
      count_removed++;
      continue;
    }
    const ls = string.lines(line.value);
    if (line.added) {
      for (const line of ls) {
        count_added++;
        text.push(`${pad(padsize, '' + count_added)} + ${line}`);
      }
    } else {
      for (const line of ls) {
        count_removed++;
        text.push(`${pad(padsize, '' + count_removed)} - ${line}`);
      }
    }
  }
  return {
    raw: lines,
    text: text.map(function(t) {
      return `${t}\n`;
    }).join('')
  };
};
