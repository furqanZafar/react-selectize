require! \browserify
require! \browserify-shim
require! \fs
require! \gulp
require! \gulp-connect
require! \gulp-if
require! \gulp-livescript
require! \gulp-rename
require! \gulp-streamify
require! \gulp-stylus
require! \gulp-uglify
require! \gulp-util
require! \nib
require! \run-sequence
{once} = require \underscore
source = require \vinyl-source-stream
require! \watchify

config = 
    minify: process.env.MINIFY == \true

# stylus-config :: Boolean -> object
stylus-config = (minify) -> 
    use: nib!
    import: <[nib]>
    compress: minify
    "include css": true

# build public/components/App.styl which requires other styl files
gulp.task \build:examples:styles, ->
    gulp.src <[./public/components/App.styl]>
    .pipe gulp-stylus (stylus-config config.minify)
    .pipe gulp.dest './public/components'
    .pipe gulp-connect.reload!

# watch all the style files both in public/components directory & themes directory
gulp.task \watch:examples:styles, -> 
    gulp.watch <[./public/components/*.styl ./themes/*.styl]>, <[build:examples:styles]>

# create a browserify Bundler
# create-bundler :: [String] -> object -> Bundler
create-bundler = (entries, extras) ->
    bundler = browserify {} <<< watchify.args <<< extras <<< {paths: <[./src ./public/components]>}
        ..add entries
        ..transform \liveify
        ..transform \brfs

# outputs a single javascript file (which is bundled and minified - depending on env)
# bundler :: Bundler -> {file :: String, directory :: String} -> IO()
bundle = (minify, bundler, {file, directory}:output) ->
    bundler.bundle!
        .on \error, -> gulp-util.log arguments
        .pipe source file
        .pipe gulp-if minify, (gulp-streamify gulp-uglify!)
        .pipe gulp.dest directory

# build-and-watch :: Bundler -> {file :: String, directory :: String} -> Boolean -> (() -> ()) -> ()
build-and-watch = (minify, bundler, {file}:output, done) !->
    # must invoke done only once
    once-done = once done

    watchified-bundler = watchify bundler

    # build once
    bundle minify, watchified-bundler, output

    watchified-bundler
        .on \update, ->
            bundle minify, watchified-bundler, output
                .pipe gulp-connect.reload!

        .on \time, (time) ->
            once-done!
            gulp-util.log "#{file} built in #{time / 1000} seconds"

examples-bundler = create-bundler [\./public/components/App.ls], debug: !config.minify
app-js = file: \App.js, directory: \./public/components/

# first, builds public/components/App.ls once, then builds it everytime there is a change
gulp.task \build-and-watch:examples:scripts, (done) ->
    build-and-watch config.minify, examples-bundler, app-js, done

gulp.task \build:themes, ->
    gulp.src <[./themes/*.styl]>
    .pipe gulp-stylus (stylus-config config.minify)
    .pipe gulp.dest \./themes

gulp.task \watch:themes, -> 
    gulp.watch <[./themes/*.styl]>, <[build:themes]>

gulp.task \build:src:scripts, ->
    gulp.src <[./src/*.ls]>
    .pipe gulp-livescript!
    .pipe gulp.dest \./src

gulp.task \watch:src:scripts, ->
    gulp.watch <[./src/*.ls]>, <[build:src:scripts]>

# create-standalone-build :: Boolean -> {file :: String, directory :: String} -> Stream
create-standalone-build = (minify, {file, directory}) ->
    browserify standalone: \react-selectize, debug: false
        .add <[./src/index.js]>
        .exclude \prelude-ls
        .exclude \prelude-extension
        .exclude \react
        .exclude \react-dom
        .exclude \react-transition-group
        .exclude \tether
        .transform browserify-shim
        .bundle!
        .on \error, -> gulp-util.log arguments
        .pipe source file
        .pipe gulp-if minify, (gulp-streamify gulp-uglify!)
        .pipe gulp.dest directory

gulp.task \dist, <[build:src:scripts]>, ->
    # create dist/index.js
    <- create-standalone-build false, {file: \index.js, directory: \./dist} .on \finish

    # create dist/index.min.js
    <- create-standalone-build true, {file: \index.min.js, directory: \./dist} .on \finish

    # create dist/index.css
    gulp.src <[./themes/index.styl]>
        .pipe gulp-stylus (stylus-config false)
        .pipe gulp.dest \./dist

    # create dist/index.min.css
    gulp.src <[./themes/index.styl]>
        .pipe gulp-stylus (stylus-config true)
        .pipe gulp-rename (path) -> path.extname = \.min.css
        .pipe gulp.dest \./dist

gulp.task \dev:server, ->
    gulp-connect.server do
        livereload: true
        port: 8000
        root: \./public/

gulp.task \build:src, <[build:themes build:src:scripts]>
gulp.task \watch:src, <[watch:themes watch:src:scripts]>
gulp.task \build:examples, <[build:examples:styles build:examples:scripts]>
gulp.task \watch:examples, <[watch:examples:styles watch:examples:scripts]>
gulp.task \default, -> run-sequence do 
    \build:src
    \watch:src
    \build:examples:styles 
    \watch:examples:styles 
    \build-and-watch:examples:scripts
    \dev:server 