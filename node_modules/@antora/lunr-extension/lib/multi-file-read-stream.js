'use strict'

const fs = require('node:fs')
const { PassThrough } = require('node:stream')

class MultiFileReadStream extends PassThrough {
  constructor (paths) {
    super()
    ;(this.queue = this.createQueue(paths)).next()
  }

  *createQueue (paths) {
    for (const path of paths) {
      fs.createReadStream(path)
        .once('error', (err) => this.destroy(err))
        .once('end', () => this.queue.next())
        .pipe(this, { end: false })
      yield
    }
    this.push(null)
  }
}

module.exports = MultiFileReadStream
