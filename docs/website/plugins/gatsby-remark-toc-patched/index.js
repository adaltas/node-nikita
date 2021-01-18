const generateTOC = require('mdast-util-toc')

const mm = require('micromatch')

module.exports = (
  { markdownNode, markdownAST },
  { include = [], header = 'Table of Contents' }
) => {
  const filePath = markdownNode.fileAbsolutePath
    .split(process.cwd())
    .pop()
    .replace(/^\//, '')
  const isIncluded = mm.isMatch(filePath, include)

  if (!isIncluded) {
    return
  }

  const toc = generateTOC(markdownAST).map

  const util = require('util')
  const filteredToc = toc.children[0].children[1]

  const index =
    markdownAST.children.findIndex(
      node => node.type === 'heading' && node.depth === 1
    ) + 1

  if (!filteredToc || index < 0) {
    return
  }

  const nodes = [
    {
      type: 'html',
      value: '<div class="toc">',
    },
    header && {
      type: 'heading',
      depth: 2,
      children: [
        {
          type: 'link',
          url: '#toc',
          title: null,
          data: {
            hProperties: {
              'aria-hidden': true,
              class: 'anchor',
            },
            hChildren: [
              {
                type: 'raw',
                // The Octicon link icon.
                value:
                  '<svg aria-hidden="true" height="16" version="1.1" viewBox="0 0 16 16" width="16"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg>',
              },
            ],
          },
        },
        {
          type: 'text',
          value: header,
        },
      ],
    },
    filteredToc,
    {
      type: 'html',
      value: '</div>',
    },
  ].filter(Boolean)
  markdownAST.children = [].concat(
    markdownAST.children.slice(0, index),
    ...nodes,
    markdownAST.children.slice(index)
  )
}
