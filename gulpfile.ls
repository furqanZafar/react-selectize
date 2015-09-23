require! \browserify
# require! \./config
require! \fs
require! \gulp
require! \gulp-connect
require! \gulp-if
require! \gulp-livescript
require! \gulp-streamify
require! \gulp-stylus
require! \gulp-uglify
require! \gulp-util
require! \nib
{basename, dirname, extname} = require \path
source = require \vinyl-source-stream
require! \watchify

config = 
    minify: process.env.MINIFY == \true

create-bundler = (entries) ->
    bundler = browserify {} <<< watchify.args <<< {debug: config.minify, paths: <[./src ./public/components]>}
        ..add entries
        ..transform \liveify
        ..transform \brfs
    watchify bundler

bundle = (bundler, {file, directory}:output) ->
    bundler.bundle!
        .on \error, -> console.log arguments
        .pipe source file
        .pipe gulp-if config.minify, (gulp-streamify gulp-uglify!)
        .pipe gulp.dest directory
        .pipe gulp-connect.reload!

##
# Examples
##
gulp.task \build:examples:styles, ->
    gulp.src <[./public/components/App.styl]>
    .pipe gulp-stylus use: nib!, import: <[nib]>, compress: config.minify
    .pipe gulp.dest './public/components'
    .pipe gulp-connect.reload!

gulp.task \watch:examples:styles, -> 
    gulp.watch <[./public/components/*.styl ./src/*.styl]>, <[build:examples:styles]>

examples-bundler = create-bundler \./public/components/App.ls
bundle-examples = -> bundle examples-bundler, {file: "App.js", directory: "./public/components/"}

gulp.task \build:examples:scripts, ->
    bundle-examples!

gulp.task \watch:examples:scripts, ->
    examples-bundler.on \update, -> bundle-examples!
    examples-bundler.on \time, (time) -> gulp-util.log "App.js built in #{time} seconds"

##
# Source
##
gulp.task \build:src:styles, ->
    gulp.src <[./src/*.styl]>
    .pipe gulp-stylus use: nib!, import: <[nib]>, compress: config.minify
    .pipe gulp.dest './src'

gulp.task \watch:src:styles, -> 
    gulp.watch <[./src/*.styl]>, <[build:src:styles]>    

gulp.task \build:src:scripts, ->
    gulp.src <[./src/*.ls]>
    .pipe gulp-livescript!
    .pipe gulp.dest './src'

gulp.task \watch:src:scripts, ->
    gulp.watch <[./src/*.ls]>, <[build:src:scripts]>

gulp.task \dev:server, ->
    gulp-connect.server do
        livereload: true
        port: 8000
        root: \./public/

gulp.task \build:src, <[build:src:styles build:src:scripts]>
gulp.task \watch:src, <[watch:src:styles watch:src:scripts]>
gulp.task \build:examples, <[build:examples:styles build:examples:scripts]>
gulp.task \watch:examples, <[watch:examples:styles watch:examples:scripts]>
gulp.task \default, <[dev:server build:src watch:src build:examples watch:examples]>