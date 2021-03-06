var	gulp = require('gulp'),
	exist = require('gulp-exist'),
	watch = require('gulp-watch'),
	filter = require('gulp-filter')
	newer = require('gulp-newer'),
	plumber = require('gulp-plumber'),
	zip = require('gulp-zip'),
	sourcemaps = require('gulp-sourcemaps'),
	rename = require('gulp-rename');

var secrets = require('./exist-secrets.json');

var sourceDir = 'app/';
var dataDir = 'app/data/';

var buildDest = 'build/';



// ------ Copy (and compile) sources and assets to build dir ----------

gulp.task('copy', function() {
	return gulp.src([sourceDir + '**/*',"!**/data/*{pub,doc}/*.xml"])
		   	.pipe(newer(buildDest))
		   	.pipe(gulp.dest(buildDest))
});

gulp.task('copy-net', function() {
    return gulp.src(["network/" + '**/*',"!**/data/**/*.xml"])
        .pipe(newer("build-network/"))
        .pipe(gulp.dest("build-network/"))
});

gulp.task('build', ['copy']);


// ------ Deploy build dir to eXist ----------

var localExist = exist.createClient({
		host: "localhost",
		port: 8080,
		path: "/exist/xmlrpc",
		basic_auth: secrets.local
	});

var remoteExist = exist.createClient({
		host: "projects.cceh.uni-koeln.de",
		port: 8080,
		path: "/xmlrpc",
		basic_auth: secrets.remote
});

exist.defineMimeTypes({ 'text/xml': ['rng'] });

var permissions = { 'controller.xql': 'rwxr-xr-x' };


gulp.task('local-upload', ['build'], function() {

	return gulp.src(buildDest + '**/*', {base: buildDest})
		.pipe(localExist.newer({target: "/db/apps/pessoa/"}))
		.pipe(localExist.dest({
			target: "/db/apps/pessoa",
			permissions: permissions
		}));
});


gulp.task('local-hard-upload', ['build'], function() {

    return gulp.src(buildDest + '**/*', {base: buildDest})
        .pipe(localExist.dest({
            target: "/db/apps/pessoa",
            permissions: permissions
        }));
});
gulp.task('network-upload', ['copy-net'], function() {

    return gulp.src("build-network/" + '**/*', {base: "build-network/"})
        .pipe(localExist.newer({target: "/db/apps/pessoa/"}))
        .pipe(localExist.dest({
            target: "/db/apps/pessoa",
            permissions: permissions
        }));
});

gulp.task('local-upload-data', function() {

	return gulp.src(dataDir + '**/*', {base: dataDir})
		.pipe(localExist.newer({target: "/db/apps/pessoa/data/"}))
		.pipe(localExist.dest({
			target: "/db/apps/pessoa/data",
			permissions: permissions
		}));
});

gulp.task('local-post-install', ['local-upload'], function() {
	return gulp.src('app/post-install.xql')
		.pipe(localExist.query());
});


gulp.task('deploy-local',['local-upload','local-upload-data','local-post-install']);

gulp.task('remote-upload', ['build'], function() {

	return gulp.src(buildDest + '**/*', {base: buildDest})
		.pipe(remoteExist.newer({target: "/db/apps/pessoa"}))
		.pipe(remoteExist.dest({
			target: "/db/apps/pessoa",
			permissions: permissions
		}));
});

gulp.task('remote-post-install', ['remote-post-redirect','remote-upload'], function() {
	return gulp.src('app/post-install.xql')
		.pipe(remoteExist.query());
});
gulp.task('remote-post-redirect', function() {
    return gulp.src('app/post-redirect.xql')
        .pipe(remoteExist.query());
});

gulp.task('deploy-remote', ['remote-upload', 'remote-post-install']);




// ------ Update Index ----------

gulp.task('upload-index-conf_doc', function(){
	return gulp.src('app/SUCHE_doc-collection.xconf')
	                       .pipe(rename('collection.xconf'))
			.pipe(localExist.dest({target: "/db/system/config/db/apps/pessoa/data/doc"}));
});
gulp.task('upload-index-conf_pub', function(){
	return gulp.src('app/SUCHE_pub-collection.xconf')
	                       .pipe(rename('collection.xconf'))
			.pipe(localExist.dest({target: "/db/system/config/db/apps/pessoa/data/pub"}));
});

gulp.task('update-index', ['upload-index-conf_doc','upload-index-conf_pub'], function() {
	return gulp.src('scripts/reindex.xql')
			.pipe(localExist.query());
});

gulp.task('upload-index-conf-remote', function(){
	return gulp.src('collection.xconf')
	                        .pipe(rename('collection.xconf'))
			.pipe(remoteExist.dest({target: "/db/system/config/db/apps/pessoa/data"}));
});

gulp.task('update-index-remote', ['upload-index-conf-remote'], function() {
	return gulp.src('scripts/reindex.xql')
			.pipe(remoteExist.query());
});



// ------ Make eXist XAR Package ----------


gulp.task('xar', ['build'], function() {
	var p = require('./package.json');

	return gulp.src(buildDest + '**/*', {base: buildDest})
			.pipe(zip(p.name + p.version + ".xar"))
			.pipe(gulp.dest("."));
});



// ------ WATCH ----------


gulp.task('watch-main', function() {
	return watch(buildDest, {
			ignoreInitial: true,
			base: buildDest,
			name: 'Main Watcher'
	})
	.pipe(plumber())
	.pipe(localExist.dest({target: "/db/apps/pessoa"}))
});
gulp.task('watch-network', function() {
    return watch("build-network/", {
        ignoreInitial: true,
        base: "build-network/",
        name: 'Network Watcher'
    })
        .pipe(plumber())
        .pipe(localExist.dest({target: "/db/apps/pessoa"}))
});

gulp.task('watch-copy', function() {
	gulp.watch([
                                    sourceDir + '**/*'
				], ['copy']);
});

gulp.task('watch-copy-net', function() {
    gulp.watch([
        "network/" + '**/*'
    ], ['copy-net']);
});

gulp.task('watch', ['watch-copy', 'watch-main']);

gulp.task('watch-net', ['watch-copy-net', 'watch-network']);