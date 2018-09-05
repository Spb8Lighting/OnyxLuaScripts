const gulp = require('gulp')
	, replace  = require('gulp-replace')
	, rename  = require('gulp-rename')
	, merge  = require('merge-stream')
	, fs = require('fs')
	, SourceLUA = ['./scripts/*.lua']
	, DeletePresets = './scripts/Delete-Presets/Delete-Presets.lua'
	, PresetsType = ['Color', 'PanTilt', 'Intensity', 'Gobo', 'Beam', 'BeamFX']

// Generate all LUA Script with HEADER include
gulp.task('build', () => {
	return gulp.src(SourceLUA)
		.pipe(replace('--##LUAHEADERINCLUDE##--', fs.readFileSync('./assets/header.lua', 'utf8') + "\n"))
		.pipe(gulp.dest('dist/'))
})
gulp.task('build:DeletePresets', () => {
    let tasks = PresetsType.map((Preset)  => {
		return gulp.src(DeletePresets)
			.pipe(rename('Delete-Presets/Delete-Presets-' + Preset + '.lua'))
			.pipe(replace('--##PRESET##--', Preset))
			.pipe(replace('--##PRESETTYPE##--', 'PresetType = "' + Preset + '"'))
			.pipe(replace('--##LUAHEADERINCLUDE##--', fs.readFileSync('./assets/header.lua', 'utf8') + "\n"))
			.pipe(gulp.dest('dist/'))
    })
    return merge(tasks)
})
// On any modification of dist file
gulp.task('watch', () => {
	gulp.watch(SourceLUA, ['build:DeletePresets'])
})
// Default task when gulp command launched
gulp.task('default', ['build:DeletePresets'], () => {
})
