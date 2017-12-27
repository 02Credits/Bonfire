// Generated by CoffeeScript 1.12.0
(function() {
  define(["jquery", "arbiter", "pouchdbManager", "moment"], function($, arbiter, PouchDB, moment) {
    var db, div, uploadFiles;
    db = new PouchDB('http://73.193.51.132:5984/attachments');
    div = document.getElementById('content');
    div.ondragenter = div.ondragover = function(e) {
      e.preventDefault();
      e.dataTransfer.dropEffect = 'copy';
      return false;
    };
    uploadFiles = function(files) {
      var blob, file, i, len, results1;
      results1 = [];
      for (i = 0, len = files.length; i < len; i++) {
        file = files[i];
        blob = file.slice();
        if (blob.size > 15000000) {
          results1.push(arbiter.publish('messages/send', {
            author: localStorage.displayName,
            text: "FILE TOO BIG"
          }));
        } else {
          results1.push(db.allDocs({
            include_docs: true,
            conflicts: false,
            limit: 1,
            descending: true,
            startkey: "_design"
          }).then(function(results) {
            var attachments, id, messageNumber, time;
            messageNumber = 0;
            if (results.rows.length > 0) {
              messageNumber = parseInt(results.rows[0].doc.messageNumber) + 1;
            }
            time = moment().utc().valueOf();
            id = messageNumber.toString() + time.toString();
            attachments = {};
            attachments[file.name] = {
              data: blob,
              content_type: file.type
            };
            return db.put({
              _id: id,
              messageNumber: messageNumber.toString(),
              _attachments: attachments
            }).then(function() {
              return arbiter.publish('messages/send', {
                author: localStorage.displayName,
                file: id
              });
            })["catch"](function(err) {
              return arbiter.publish("error", err);
            });
          }));
        }
      }
      return results1;
    };
    return div.ondrop = function(e) {
      var error, sent, url;
      try {
        url = e.dataTransfer.getData('URL');
        sent = false;
        if (url !== "") {
          sent = true;
          $('.progress').fadeIn();
          $.ajax({
            url: 'https://api.imgur.com/3/image',
            headers: {
              'Authorization': 'Client-ID c110ed33b325faf'
            },
            type: 'POST',
            data: {
              'image': url,
              'Authorization': 'Client-ID c110ed33b325faf'
            },
            success: function(result) {
              arbiter.publish('messages/send', {
                text: result.data.link,
                author: localStorage.displayName
              });
              return $('.progress').fadeOut();
            },
            error: function() {
              Materialize.toast("Image URL Upload Failed", 4000);
              return $('.progress').fadeOut();
            }
          });
        } else {
          if (e.dataTransfer.files.length !== 0) {
            uploadFiles(e.dataTransfer.files);
          }
        }
      } catch (error1) {
        error = error1;
        arbiter.publish('error', error);
      }
      return e.preventDefault();
    };
  });

}).call(this);
