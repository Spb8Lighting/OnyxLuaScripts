const gulp = require('gulp')
	, replace = require('gulp-replace')
	, rename = require('gulp-rename')
	, merge = require('merge-stream')
	, zip = require('gulp-zip')
	, fs = require('fs')
	, PresetsType = ['Color', 'PanTilt', 'Intensity', 'Gobo', 'Beam', 'BeamFX']

gulp.task('build', () => {
	return gulp.src('./scripts/*.lua')
		.pipe(replace('--##LUAHEADERINCLUDE##--', fs.readFileSync('./assets/header.lua', 'utf8') + "\n"))
		.pipe(gulp.dest('./dist/'))
})

gulp.task('release:zip', () => {
	fs.unlink('./release/Onyx-Lua-ShowCockpit.zip', () => {
		return gulp.src('./dist/**/*')
			.pipe(zip('Onyx-Lua-ShowCockpit.zip'))
			.pipe(gulp.dest('./release/'))
	})
})

// On any modification of dist file
gulp.task('watch', () => {
	gulp.watch('./scripts', ['build', 'build'])
})
// Default task when gulp command launched
gulp.task('default', ['build'], () => {
})
