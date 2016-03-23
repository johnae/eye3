fs = require "fs"
insert = table.insert

describe 'fs', ->

  after_each ->
    fs.rm_rf '/tmp/eye3-fs-spec'

  it 'mkdir_p creates directory structures', ->
    fs.mkdir_p '/tmp/eye3-fs-spec/my/dir/structure'
    assert.true fs.is_dir '/tmp/eye3-fs-spec/my/dir/structure'

  it 'is_dir returns true for en existing directory and false if not a dir or missing', ->
    assert.false fs.is_dir '/tmp/eye3-fs-spec'
    fs.mkdir_p '/tmp/eye3-fs-spec'
    assert.true fs.is_dir '/tmp/eye3-fs-spec'

  it 'is_file returns true for en existing file and false if not a file or missing', ->
    fs.mkdir_p '/tmp/eye3-fs-spec'
    assert.false fs.is_file '/tmp/eye3-fs-spec'
    assert.false fs.is_file '/tmp/eye3-fs-spec/myfile.txt'
    f = assert io.open('/tmp/eye3-fs-spec/myfile.txt', "w")
    f\write "hello"
    f\close!
    assert.true fs.is_file '/tmp/eye3-fs-spec/myfile.txt'

  it 'is_present returns true for either files or directories', ->
    fs.mkdir_p '/tmp/eye3-fs-spec'
    f = assert io.open('/tmp/eye3-fs-spec/myfile.txt', "w")
    f\write "hello"
    f\close!
    assert.true fs.is_present '/tmp/eye3-fs-spec'
    assert.true fs.is_present '/tmp/eye3-fs-spec/myfile.txt'

  it 'rm_rf removes directory structures', ->
    fs.mkdir_p '/tmp/eye3-fs-spec/my/dir/structure'
    assert.true fs.is_dir '/tmp/eye3-fs-spec/my/dir/structure'
    fs.rm_rf '/tmp/eye3-fs-spec'
    assert.false fs.is_dir '/tmp/eye3-fs-spec'

  describe 'dirtree', ->

    it 'dirtree by default yields only the contents of specified dir', ->
      fs.mkdir_p '/tmp/eye3-fs-spec/my/dir/structure'
      contents = {}
      for entry, attr in fs.dirtree '/tmp/eye3-fs-spec'
        insert contents, entry
      assert.same {
        '/tmp/eye3-fs-spec/my'
      }, contents


    it 'dirtree yields contents of a directory structure recursively when specified', ->
      fs.mkdir_p '/tmp/eye3-fs-spec/my/dir/structure'
      f = assert(io.open('/tmp/eye3-fs-spec/my/dir/file.txt', "w"))
      f\write("spec")
      f\close!
      contents = {}
      for entry, attr in fs.dirtree '/tmp/eye3-fs-spec', true
        insert contents, entry
      expected = {
        '/tmp/eye3-fs-spec/my',
        '/tmp/eye3-fs-spec/my/dir',
        '/tmp/eye3-fs-spec/my/dir/structure',
        '/tmp/eye3-fs-spec/my/dir/file.txt'
      }
      table.sort(expected)
      table.sort(contents)
      assert.same expected, contents
