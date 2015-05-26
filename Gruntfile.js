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

        shell: {
            add: {
                command: [
                    "git add -u",
                    "git add GruntFile.js",
                    "git add package.json",
                    "git add src/*"
                ].join('&&')
            },
            commit: {
                command: "git commit -m \"Auto Commit\""
            },
            push: {
                command: "git push"
            },
            pull: {
                command: "git pull"
            }
        }
    });

    grunt.registerTask('gitCommit', [ 'shell:add', "shell:commit" ]);
    grunt.registerTask('git', [ 'gitCommit', 'shell:push' ]);
    grunt.registerTask('build', [ 'gitCommit', 'clean:build', 'copy', 'babel']);
    grunt.registerTask('package',
                       [
                           'git',
                           'clean:dist',
                           'electron',
                           'create-windows-installer'
                       ]);

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
