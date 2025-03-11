'use strict'

/**
 * Splitting the text by the given positions.
 * The text within the positions getting the type "mark", all other text gets the type "text".
 * @param {string} text
 * @param {Object[]} positions
 * @param {number} positions.start
 * @param {number} positions.length
 * @param {number} snippetLength Maximum text length for text in the result.
 * @returns {[{text: string, type: string}]}
 */
export function buildHighlightedText (text, positions, snippetLength) {
  const textLength = text.length
  const validPositions = positions.filter(
    (position) => position.length > 0 && position.start + position.length <= textLength
  )

  if (validPositions.length === 0) {
    return [
      {
        type: 'text',
        text:
          text.slice(0, snippetLength >= textLength ? textLength : snippetLength) +
          (snippetLength < textLength ? '...' : ''),
      },
    ]
  }

  const orderedPositions = validPositions.sort((p1, p2) => p1.start - p2.start)
  const range = {
    start: 0,
    end: textLength,
  }
  const firstPosition = orderedPositions[0]
  if (snippetLength && text.length > snippetLength) {
    const firstPositionStart = firstPosition.start
    const firstPositionLength = firstPosition.length
    const firstPositionEnd = firstPositionStart + firstPositionLength

    range.start = firstPositionStart - snippetLength < 0 ? 0 : firstPositionStart - snippetLength
    range.end = firstPositionEnd + snippetLength > textLength ? textLength : firstPositionEnd + snippetLength
  }
  const nodes = []
  if (firstPosition.start > 0) {
    nodes.push({
      type: 'text',
      text: (range.start > 0 ? '...' : '') + text.slice(range.start, firstPosition.start),
    })
  }
  let lastEndPosition = 0
  const positionsWithinRange = orderedPositions.filter(
    (position) => position.start >= range.start && position.start + position.length <= range.end
  )

  for (const position of positionsWithinRange) {
    const start = position.start
    const length = position.length
    const end = start + length
    if (lastEndPosition > 0) {
      // create text Node from the last end position to the start of the current position
      nodes.push({
        type: 'text',
        text: text.slice(lastEndPosition, start),
      })
    }
    nodes.push({
      type: 'mark',
      text: text.slice(start, end),
    })
    lastEndPosition = end
  }
  if (lastEndPosition < range.end) {
    nodes.push({
      type: 'text',
      text: text.slice(lastEndPosition, range.end) + (range.end < textLength ? '...' : ''),
    })
  }

  return nodes
}

/**
 * Taken and adapted from: https://github.com/olivernn/lunr.js/blob/aa5a878f62a6bba1e8e5b95714899e17e8150b38/lib/tokenizer.js#L24-L67
 * @param lunr
 * @param text
 * @param term
 * @return {{start: number, length: number}}
 */
export function findTermPosition (lunr, term, text) {
  const str = text.toLowerCase()
  const index = str.indexOf(term)

  if (index >= 0) {
    // extend term until word boundary to return the entire word
    const boundaries = str.substr(index).match(/^[\p{Alpha}]+/u)
    if (boundaries !== null && boundaries.length >= 0) {
      return {
        start: index,
        length: boundaries[0].length,
      }
    }
  }

  // Not found
  return {
    start: 0,
    length: 0,
  }
}
