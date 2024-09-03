/*
# Diff

Report the difference between 2 strings.
*/

// ## Dependencies
import pad from "pad";
import { diffLines } from "diff";
import string from "@nikitajs/utils/string";

// Utils
export default function (oldStr, newStr) {
  if (oldStr == null) {
    oldStr = "";
  }
  if (newStr == null) {
    newStr = "";
  }
  const lines = diffLines(oldStr, newStr);
  let text = [];
  let count_added = 0;
  let count_removed = 0;
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
        text.push(`${pad(padsize, "" + count_added)} + ${line}`);
      }
    } else {
      for (const line of ls) {
        count_removed++;
        text.push(`${pad(padsize, "" + count_removed)} - ${line}`);
      }
    }
  }
  return {
    raw: lines,
    text: text
      .map(function (t) {
        return `${t}\n`;
      })
      .join(""),
  };
}
