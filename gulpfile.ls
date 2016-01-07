require! \gulp
require! \gulp-livescript
require! \gulp-mocha
{instrument, hook-require, write-reports} = (require \gulp-livescript-istanbul)!

gulp.task \build, ->
    gulp.src <[./index.ls ./transformation-context.ls]>
    .pipe gulp-livescript!
    .pipe gulp.dest \./

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