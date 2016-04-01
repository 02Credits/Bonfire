start cmd /c "coffee -o server/static/bin -cw server/static/src"
start cmd /c "node-sass ./server/static/src --output ./server/static/bin"
start cmd /c "node-sass --watch ./server/static/src --output ./server/static/bin"