module.exports = function(grunt) {
    require("load-grunt-tasks")(grunt);
    var exec = require('child_process').exec;

    grunt.initConfig({
        copy: {
            build: {
                cwd: 'client',
                src: [ '**', '!**/*.coffee', '!**/*.js', '!**/*.sass', '!**/*.scss', '!**/*.tern-port' ],
                dest: 'build',
                expand: true
            }
        },
        babel: {
            build: {
                cwd: 'client',
                src: [ '**/*.js' ],
                dest: 'build',
                expand: true
            }
        },
        coffee: {
            build: {
                cwd: 'client',
                src: [ '**/*.coffee' ],
                dest: 'build',
                expand: true,
                ext: '.js'
            }
        },
        sass: {
            build: {
                cwd: 'client',
                src: [ '**/*.sass', '**/*.scss' ],
                dest: 'build',
                expand: true,
                ext: '.css'
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
            windowsBuild: {
                options: {
                    name: 'Bonfire',
                    dir: 'build',
                    out: 'dist',
                    version: '0.30.1',
                    platform: 'win32',
                    arch: 'ia32',
                    icon: './BFiconFinished.ico',
                    asar: true,
                    "version-string": {
                        CompanyName: "02Credits LLC",
                        LegalCopyright: "Copyright 2015 02Credits LLC",
                        FileDescription: "An extensible chat application",
                        OriginalFileName: "Bonfire.exe",
                        ProductName: "Bonfire",
                        InternalName: "Bonfire"
                    }
                }
            }
        },
        "create-windows-installer": {
            appDirectory: "dist/Bonfire-win32",
            outputDirectory: "installer",
            authors: "02Credits LLC",
            exe: "Bonfire.exe",
            description: "An extensible chat application.",
            title: "Bonfire",
            setupIcon: "./BFiconFinished.ico",
            iconUrl: "http://the-simmons.dnsalias.net/BFiconFinished.ico"
        },

        shell: {
            add: {
                command: [
                    "git add -u",
                    "git add GruntFile.js",
                    "git add package.json",
                    "git add client/*"
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
        },

        bump: {
            options: {
                level: "patch"
            },
            src: [ "client/package.json" ]
        }
    });

    grunt.registerTask('gitCommit', [ 'shell:add', "shell:commit" ]);
    grunt.registerTask('git', [ 'shell:pull', 'gitCommit', 'shell:push' ]);
    grunt.registerTask('build', [ 'clean:build', 'copy', 'babel', 'coffee', 'sass' ]);
    grunt.registerTask('package',
                       [
                           'bump',
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
