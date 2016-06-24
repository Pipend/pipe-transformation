require! \browserify
require! \gulp
require! \gulp-livescript
require! \gulp-mocha
{instrument, hook-require, write-reports} = (require \gulp-livescript-istanbul)!
require! \gulp-streamify
require! \gulp-uglify
{each} = require \prelude-ls
source = require \vinyl-source-stream

gulp.task \build, ->
    gulp.src <[./index.ls ./transformation-context.ls]>
    .pipe gulp-livescript!
    .pipe gulp.dest \./

gulp.task \dist, <[build]>, ->
    [
        <[./index pipeTransformation]>
        <[./transformation-context transformationContext]>
    ] |> each ([file-name, export-name]) ->
        browserify standalone: export-name, debug: false
            .add "#{file-name}.js"
            .exclude \highland
            .exclude \JSONStream
            .exclude \moment
            .exclude \prelude-ls
            .exclude \prelude-extension
            .exclude \rx
            .exclude \socket.io-client
            .exclude \stream
            .exclude \transpilation
            .exclude \./transformation-context
            .bundle!
            .pipe source "#{file-name}.min.js"
            .pipe (gulp-streamify gulp-uglify!)
            .pipe gulp.dest \./dist

gulp.task \watch, ->
    gulp.watch <[./index.ls ./transformation-context.ls]>, <[build]>

gulp.task \coverage, ->
    gulp.src <[./index.ls ./transformation-context.ls]>
    .pipe instrument!
    .pipe hook-require!
    .on \finish, ->
        gulp.src <[./test/index.ls]>
        .pipe gulp-mocha!
        .pipe write-reports!
        .on \finish, -> process.exit!

gulp.task \default, <[build watch]>