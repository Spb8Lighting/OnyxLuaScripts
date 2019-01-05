const gulp = require('gulp')
	, replace = require('gulp-replace')
	, rename = require('gulp-rename')
	, merge = require('merge-stream')
	, zip = require('gulp-zip')
	, fs = require('fs')
const Scripts = {
	AutoPresets: {
		LUA: 'Onyx-Auto-Presets.lua',
		Header : {
			Match : '--##LUAPRESETSINCLUDE##--',
			Replace : 'Auto-Presets.lua'
		}
	},
	CreatePlaybackFromPresets: {
		LUA: 'Onyx-Create-Playbacks-from-Presets.lua'
	},
	DeleteCuelists: {
		LUA: 'Onyx-Delete-Cuelists.lua'
	},
	DeleteGroups: {
		LUA: 'Onyx-Delete-Groups.lua'
	},
	DeletePresets: {
		LUA: 'Onyx-Delete-Presets.lua'
	},
	RenameCuelists: {
		LUA: 'Onyx-Rename-Cuelists.lua'
	},
	UpdateCueFadeCuelistRelease: {
		LUA: 'Onyx-Update-CueFade-CuelistRelease.lua'
	}
}
let Specific = {
	Builder: (ScriptObj, ScriptName) => {
		gulp.task('build:' + ScriptName, () => {
			if (ScriptObj.Header) {
				return gulp.src('./scripts/' + ScriptObj.LUA)
					.pipe(replace('--##LUAHEADERINCLUDE##--', fs.readFileSync('./assets/header.lua', 'utf8') + "\n"))
					.pipe(replace(ScriptObj.Header.Match, fs.readFileSync('./assets/' + ScriptObj.Header.Replace, 'utf8') + "\n"))
					.pipe(gulp.dest('./dist/'))
			} else {
				return gulp.src('./scripts/' + ScriptObj.LUA)
					.pipe(replace('--##LUAHEADERINCLUDE##--', fs.readFileSync('./assets/header.lua', 'utf8') + "\n"))
					.pipe(gulp.dest('./dist/'))
			}
		})
	},
	Watcher: (ScriptObj, ScriptName) => {
		gulp.task('watch:' + ScriptName, () => {
			gulp.watch('./scripts/' + ScriptObj.LUA, ['build:' + ScriptName])
			if (ScriptObj.Header) {
				gulp.watch('./assets/' + ScriptObj.Header, ['build:' + ScriptName])
			}
		})
	}
}
// Create Release Archive Build
gulp.task('release:zip', () => {
	fs.unlink('./release/Onyx-Lua-ShowCockpit.zip', () => {
		return gulp.src('./dist/**/*')
			.pipe(zip('Onyx-Lua-ShowCockpit.zip'))
			.pipe(gulp.dest('./release/'))
	})
})

// On any modification of dist file
gulp.task('watch', () => {
	gulp.watch('./scripts/**/*', ['build'])
	gulp.watch('./assets/**/*', ['build'])
})
// Default task when gulp command launched
gulp.task('default', ['build', 'watch'], () => {
})
// Generic Build
gulp.task('build', () => {
	for (let Script in Scripts) {
		gulp.start('build:' + Script);
	}
})
// Generate all specific builder and watcher per script
for (let Script in Scripts) {
	Specific.Builder(Scripts[Script], Script)
	Specific.Watcher(Scripts[Script], Script)
}