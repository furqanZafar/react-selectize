browserify = require \browserify
fs = require \fs
gulp = require \gulp
gulp-browserify = require \gulp-browserify 
gulp-connect = require \gulp-connect
gulp-util = require \gulp-util
stylus = require \gulp-stylus
{basename, dirname, extname} = require \path
source = require \vinyl-source-stream
watchify = require \watchify

create-bundler = (entries) ->
    bundler = browserify {} <<< watchify.args <<< {debug: true}
    bundler.add entries
    bundler.transform \liveify
    watchify bundler    

bundle = (bundler, {file, directory}:output) ->
    bundler.bundle!
        .on \error, -> console.log arguments
        .pipe source file
        .pipe gulp.dest directory
        .pipe gulp-connect.reload!        

##
#
##
gulp.task \build:examples:styles, ->
    gulp.src <[./examples/src/App.styl]>
    .pipe stylus!
    .pipe gulp.dest './examples/dist'
    .pipe gulp-connect.reload!

gulp.task \watch:examples:styles, -> 
    gulp.watch <[./examples/src/*.styl ./src/*.styl]>, <[build:examples:styles]>    

examples-bundler = create-bundler \./examples/src/App.ls
bundle-examples = -> bundle examples-bundler, {file: "App.js", directory: "./examples/dist/"}

gulp.task \build:examples:scripts, ->        
    bundle-examples!

gulp.task \watch:examples:scripts, ->    
    examples-bundler.on \update, -> bundle-examples!
    examples-bundler.on \time, (time) -> gulp-util.log "App.js built in #{time} seconds"

##
#
##
gulp.task \build:src:styles, ->
    gulp.src <[./src/react-selectize.styl]>
    .pipe stylus!
    .pipe gulp.dest './dist'
    .pipe gulp-connect.reload!

gulp.task \watch:src:styles, -> 
    gulp.watch <[./src/*.styl]>, <[build:src:styles]>    

src-bundler = create-bundler \./src/react-selectize.ls
bundle-src = -> bundle examples-bundler, {file: "react-selectize.js", directory: "./dist/"}

gulp.task \build:src:scripts, ->        
    bundle-src!

gulp.task \watch:src:scripts, ->    
    src-bundler.on \update, -> bundle-src!
    src-bundler.on \time, (time) -> gulp-util.log "react-selectize.js built in #{time} seconds"

gulp.task \dev:server, ->
    gulp-connect.server {
        root: \./examples/
        port: 8000
        livereload: true
    }

gulp.task \build:src, <[build:src:styles build:src:scripts]>
gulp.task \watch:src, <[watch:src:styles watch:src:scripts]>
gulp.task \build:examples, <[build:examples:styles build:examples:scripts]>
gulp.task \watch:examples, <[watch:examples:styles watch:examples:scripts]>
gulp.task \default, <[dev:server build:examples watch:examples]>





























