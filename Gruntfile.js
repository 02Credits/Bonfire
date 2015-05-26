module.exports = function(grunt) {
    require("load-grunt-tasks")(grunt);
    var exec = require('child_process').exec;

    grunt.initConfig({
        copy: {
            build: {
                cwd: 'src',
                src: [ '**', '!**/*.js', '!**/*.tern-port' ],
                dest: 'build',
                expand: true
            }
        },
        babel: {
            build: {
                cwd: 'src',
                src: [ '**/*.js' ],
                dest: 'build',
                expand: true
            }
        },
        clean: {
            build: {
                src: [ 'build' ]
            },
            dist: {
                src: [ 'dist' ]
            }
        },
        electron: {
            options: {
                name: 'Bonfire',
                dir: 'build',
                out: 'dist',
                version: '0.26.1',
                platform: 'win32',
                arch: 'ia32'
            }
        },
        'create-windows-installer': {
            appDirectory: 'dist/Bonfire-win32',
            outputDirectory: 'installer',
            authors: '02Credits LLC',
            exe: 'Bonfire.exe',
            description: 'An extensible chat application.'
        },

        gitadd: {
            options: {
                all: true
            },
            files: {
                cwd: 'src',
                src: [ '**' ],
                expand: true
            }
        },
        gitcommit: {
            files: {
                cwd: 'src',
                src: [ '**' ],
                expand: true
            }
        },
        gitpush: {}
    });

    grunt.registerTask(
        'build',
        'Compiles all of the assets and copies the files to the build directory.',
        [ 'clean:build', 'copy', 'babel', 'coffee' ]
    );

    grunt.registerTask('package', [ 'clean:dist', 'electron', 'create-windows-installer']);

    grunt.registerTask('run', function() {
        var done = this.async();
        exec(__dirname + '/node_modules/electron-prebuilt/dist/electron.exe build',
             function(error, stdout, stderr) {
                 if (error != null) {
                     console.log(stderr);
                     done(false);
                 } else {
                     done(true);
                 }
             });
    });

    grunt.registerTask('default', [ 'build', 'run' ]);
};
