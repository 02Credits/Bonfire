// Generated by CoffeeScript 1.12.0
(function() {
  define(["mithril", "arbiter", "pouchdbManager"], function(m, arbiter, PouchDB) {
    var db;
    db = new PouchDB('http://73.193.51.132:5984/attachments');
    return {
      name: "imageAttachments",
      parent: "images",
      render: function(doc, renderChildren) {
        return (renderChildren(doc)).then(function(children) {
          var file, renderedFiles, thenables;
          if ((doc.file != null) || (doc.files != null)) {
            if (doc.file) {
              doc.files = [doc.file];
            }
            renderedFiles = [];
            thenables = (function() {
              var i, len, ref, results;
              ref = doc.files;
              results = [];
              for (i = 0, len = ref.length; i < len; i++) {
                file = ref[i];
                results.push(new Promise(function(resolve, reject) {
                  var id;
                  arbiter.publish("files/fetch", file);
                  return id = arbiter.subscribe("file/data", function(fileData) {
                    if (fileData.id === file) {
                      if (fileData.attachment.content_type.startsWith("image")) {
                        renderedFiles.push(m("img.materialboxed", {
                          src: URL.createObjectURL(fileData.attachment.data)
                        }));
                      }
                      arbiter.unsubscribe(id);
                      return resolve();
                    }
                  });
                }));
              }
              return results;
            })();
            return Promise.all(thenables).then(function() {
              return [renderedFiles, children];
            });
          } else {
            return [children];
          }
        });
      }
    };
  });

}).call(this);
